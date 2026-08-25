# Feature Specification: Task 06 - User Profile & Goal Management (Mobile App)

## 1. Overview & Goal

The **User Profile & Goal Management** feature is a mobile-first experience within the Bite Flutter application that enables users to view, manage, and update their physical attributes (Age, Height, Weight, Gender, Activity Level, Primary Goal) and view auto-calculated metabolic targets (BMR, TDEE, Target Calories, Target Protein, Carbs, and Fat).

### Key Objectives:
* **Mobile-First Metabolic Profile View**: Clean, scrollable mobile dashboard displaying user stats alongside auto-calculated Mifflin-St Jeor metabolic metrics:
  * **BMR** (Basal Metabolic Rate): Energy expended at rest (kcal/day).
  * **TDEE** (Total Daily Energy Expenditure): Energy expended based on physical activity level.
  * **Target Calories & Macro Split**: Daily target calories alongside Protein (g), Carbs (g), and Fat (g) goals tailored to the user's primary objective (`muscle_gain`, `fat_loss`, `maintenance`).
* **Mobile Interactive Profile Metric Editor**: Provide a smooth mobile modal bottom sheet / full-screen editor with touch-friendly input fields, choice chips (`gender`, `activity_level`, `primary_goal`), and numeric sliders/pickers (`age`, `height_cm`, `weight_kg`).
* **Instant Metabolic Re-calculation**: Atomically persist updates via `PUT /api/v1/profile`, updating user targets and automatically triggering dashboard recalculation.
* **Design Reference Alignment**: Adhere to the Emerald Design System ([DESIGN_REFERENCE.md](file:///home/jiggra/BiteFrontEnd/DESIGN_REFERENCE.md)) with `GoogleFonts.inter`, `#10B981` primary accents, M3 rounded cards, 48dp minimum touch targets, and mobile bottom navigation tab integration.

---

## 2. API & Data Contracts

All endpoints require HTTP Bearer JWT Token (`Authorization: Bearer <access_token>`).

### 2.1 Get User Profile & Macro Targets (`GET /api/v1/profile`)
* **Path**: `/api/v1/profile`
* **Method**: `GET`
* **Auth Required**: Yes (`Bearer Token`)
* **Response** (`UserProfileResponseModel` - `200 OK`):
  ```json
  {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "display_name": "Alex Morgan",
    "height_cm": 178.0,
    "weight_kg": 75.0,
    "age": 28,
    "gender": "male",
    "activity_level": "moderate",
    "primary_goal": "muscle_gain",
    "bmr": 1720.0,
    "tdee": 2666.0,
    "target_calories": 2400.0,
    "target_protein_g": 180.0,
    "target_carbs_g": 250.0,
    "target_fat_g": 70.0,
    "target_micronutrients": {}
  }
  ```

### 2.2 Update Profile & Re-calculate BMR/TDEE (`PUT /api/v1/profile`)
* **Path**: `/api/v1/profile`
* **Method**: `PUT`
* **Auth Required**: Yes (`Bearer Token`)
* **Request Body** (`UserProfileUpdateModel`):
  ```json
  {
    "display_name": "Alex Morgan",
    "height_cm": 180.0,
    "weight_kg": 77.0,
    "age": 29,
    "gender": "male",
    "activity_level": "active",
    "primary_goal": "muscle_gain"
  }
  ```
* **Response**: `UserProfileResponseModel` (`200 OK`).

---

## 3. Layered Architecture Breakdown

```text
lib/
└── features/
    └── profile/
        ├── data/
        │   ├── datasources/
        │   │   └── profile_remote_data_source.dart # Dio HTTP GET/PUT requests for profile
        │   ├── models/
        │   │   ├── user_profile_response_model.dart # DTO for User Profile (Existing)
        │   │   └── user_profile_update_model.dart  # DTO for Profile Update (Existing)
        │   └── repositories/
        │       └── profile_repository.dart      # Repository isolating remote datasource & error mapping
        └── presentation/
            ├── providers/
            │   └── profile_provider.dart         # AsyncNotifier managing UserProfile state & updates
            ├── screens/
            │   └── profile_screen.dart           # Main mobile profile screen
            └── widgets/
                ├── profile_header_card.dart      # Avatar, Display Name, & Quick Edit action button
                ├── bmr_tdee_card.dart            # Highlight card displaying BMR, TDEE, & Target Calories
                ├── target_macros_card.dart       # Card detailing target Protein, Carbs, & Fat split
                ├── user_info_card.dart           # Attributes list card (Age, Height, Weight, Gender)
                └── edit_profile_bottom_sheet.dart # Mobile modal bottom sheet form for updating metrics
```

---

## 4. State Management Design

### 4.1 Riverpod Providers
* `profileRepositoryProvider`: Supplies `ProfileRepository` implementation.
* `profileNotifierProvider`: `AsyncNotifierProvider<ProfileNotifier, UserProfileResponseModel>`
  * **State**: `AsyncValue<UserProfileResponseModel>`
  * **Methods**:
    * `build()`: Automatically fetches user profile upon build via `ProfileRepository.getProfile()`.
    * `fetchProfile()`: Re-queries `/api/v1/profile` from backend.
    * `updateProfile(UserProfileUpdateModel request)`: Submits updated physical metrics via `ProfileRepository.updateProfile()`, updates provider state with fresh BMR/TDEE recalculations, and invalidates daily dashboard cache to sync targets across the mobile app.

---

## 5. Mobile UI & Layout Guidelines

Aligned with [DESIGN_REFERENCE.md](file:///home/jiggra/BiteFrontEnd/DESIGN_REFERENCE.md):
* **Theme & Colors**:
  * Primary Emerald Green: `#059669` / `#10B981` (`AppColors.primary`)
  * Secondary Calories Accent: `#EA580C` (`AppColors.calories`)
  * Protein Accent: `#2563EB` (`AppColors.protein`)
  * Carbs Accent: `#D97706` (`AppColors.carbs`)
  * Fat Accent: `#059669` (`AppColors.fat`)
  * Card Surfaces: Light Slate Surface (`AppColors.lightSurface`) with soft shadows (`AppRadius.lg` / 16px border radius).
* **Mobile Touch Targets**: Minimum 48dp height for all buttons, input fields, and choice chips.

### 5.1 Mobile Profile Screen Layout (`ProfileScreen`)
1. **Top Mobile Bar**: Title "Profile & Goals" with user avatar initials and edit icon action.
2. **User Profile Header Card (`ProfileHeaderCard`)**:
   * Circular avatar with user initials.
   * Display Name & Email.
   * Primary Goal pill badge (`Muscle Gain`, `Fat Loss`, `Maintenance`).
   * "Edit Metrics" elevated button.
3. **Metabolic Summary Card (`BmrTdeeCard`)**:
   * Dual metric cards: BMR (kcal/day) and TDEE (kcal/day).
   * Calorie Goal Banner: Total daily target calories highlighted with citrus orange accent.
4. **Target Macro Split Card (`TargetMacrosCard`)**:
   * Protein Target Progress Indicator (g).
   * Carbs Target Progress Indicator (g).
   * Fat Target Progress Indicator (g).
5. **Physical Attributes Card (`UserInfoCard`)**:
   * List tiles for Height (cm), Weight (kg), Age, Gender, and Activity Level.

### 5.2 Mobile Edit Profile Bottom Sheet (`EditProfileBottomSheet`)
* Triggered when tapping "Edit Metrics" or the edit action icon.
* Form layout wrapped in `SingleChildScrollView` with `Padding(viewInsets.bottom)` for mobile keyboard safety:
  * Display Name input field.
  * Age, Height (cm), Weight (kg) numeric inputs with `TextInputType.number`.
  * Gender Segmented Button (`male` / `female`).
  * Activity Level choice chips (`sedentary`, `light`, `moderate`, `active`, `very_active`).
  * Primary Goal choice chips (`fat_loss`, `maintenance`, `muscle_gain`).
* Sticky "Save Changes" mobile button with loading spinner state and error alert banners.

---

## 6. Testing & Verification Checklist

### 6.1 Unit Tests
* **`ProfileRemoteDataSourceTest`**: Test `GET /api/v1/profile` and `PUT /api/v1/profile` response parsing and Dio exception handling.
* **`ProfileRepositoryTest`**: Test repository methods and server error mapping.
* **`ProfileNotifierTest`**: Test state updates (`AsyncValue.loading` → `AsyncValue.data`, update metric execution, error state).

### 6.2 Widget Tests
* **`ProfileScreenTest`**: Verify rendering of metabolic cards, macro target cards, and physical metrics.
* **`EditProfileBottomSheetTest`**: Test opening bottom sheet, filling form fields, validation, and save trigger.

### 6.3 Static Analysis & Code Quality
```bash
# Code formatting check
dart format --output=none --set-exit-if-changed .

# Static analysis
flutter analyze
```
