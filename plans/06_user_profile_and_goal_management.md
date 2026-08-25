# Implementation Plan: Task 06 - User Profile & Goal Management

## Overview
This document details the step-by-step implementation plan for Task 06 (**User Profile & Goal Management**), based on [specs/06_user_profile_and_goal_management.md](file:///home/jiggra/BiteFrontEnd/specs/06_user_profile_and_goal_management.md).

No production code modifications will be executed in this step; this plan outlines the architecture, file creation sequence, state management workflow, UI widget hierarchy, and verification steps.

---

## 🏗 Architecture & File Structure

```text
lib/
├── core/
│   └── constants/
│       └── api_constants.dart                    # Add static const String profile = '/profile'
└── features/
    └── profile/
        ├── data/
        │   ├── datasources/
        │   │   └── profile_remote_data_source.dart # Dio GET & PUT requests for /api/v1/profile
        │   ├── models/
        │   │   ├── user_profile_response_model.dart # Existing DTO for profile response
        │   │   └── user_profile_update_model.dart  # Existing DTO for profile update
        │   └── repositories/
        │       └── profile_repository.dart      # Repository isolating remote datasource
        └── presentation/
            ├── providers/
            │   └── profile_provider.dart         # AsyncNotifierProvider<ProfileNotifier, UserProfileResponseModel>
            ├── screens/
            │   └── profile_screen.dart           # Main mobile profile screen
            └── widgets/
                ├── profile_header_card.dart      # Avatar, Display Name, Email, Goal Badge, Edit Button
                ├── bmr_tdee_card.dart            # Metabolic cards (BMR, TDEE, Target Calories)
                ├── target_macros_card.dart       # Target Macro split progress bars (Protein, Carbs, Fat)
                ├── user_info_card.dart           # Physical metrics list tile card
                └── edit_profile_bottom_sheet.dart # Mobile bottom sheet form for editing metrics
```

---

## 🗓 Sequential Implementation Roadmap

### Phase 1: Core Constants & Data Layer (`lib/features/profile/data/`)
* **Goal**: Configure API constants, Dio remote data source, and repository implementation.
* **Target Files**:
  * [MODIFY] `lib/core/constants/api_constants.dart` (`static const String profile = '/profile';`)
  * [NEW] `lib/features/profile/data/datasources/profile_remote_data_source.dart`
  * [NEW] `lib/features/profile/data/repositories/profile_repository.dart`
  * [NEW] `test/features/profile/data/profile_remote_data_source_test.dart`
  * [NEW] `test/features/profile/data/profile_repository_test.dart`
* **Tasks**:
  1. Add `profile = '/profile'` to `ApiConstants`.
  2. Implement `ProfileRemoteDataSource`:
     * `getProfile()` (`GET /api/v1/profile`)
     * `updateProfile(UserProfileUpdateModel request)` (`PUT /api/v1/profile`)
  3. Implement `ProfileRepository` and `profileRepositoryProvider`.
  4. Write unit tests for remote data source and repository.

---

### Phase 2: State Management & Riverpod Notifiers (`lib/features/profile/presentation/providers/`)
* **Goal**: Implement `ProfileNotifier` for asynchronous fetching, caching, and atomic updates.
* **Target Files**:
  * [NEW] `lib/features/profile/presentation/providers/profile_provider.dart`
  * [NEW] `test/features/profile/presentation/profile_notifier_test.dart`
* **Tasks**:
  1. Implement `ProfileNotifier`: `AsyncNotifier<UserProfileResponseModel>`
     * `build()`: Fetches profile on initial build.
     * `fetchProfile()`: Refreshes profile state.
     * `updateProfile(UserProfileUpdateModel request)`: Executes `PUT /api/v1/profile`, updates state with recalculated BMR/TDEE response, and invalidates `dailyDashboardProvider`.
  2. Write unit tests for `ProfileNotifier` state transitions (`AsyncValue.loading` → `AsyncValue.data`, update metric execution, error state).

---

### Phase 3: Mobile UI Components & Screens (`lib/features/profile/presentation/`)
* **Goal**: Build mobile-first, Emerald-themed UI cards and edit bottom sheet matching [DESIGN_REFERENCE.md](file:///home/jiggra/BiteFrontEnd/DESIGN_REFERENCE.md).
* **Target Files**:
  * [NEW] `lib/features/profile/presentation/widgets/profile_header_card.dart`
  * [NEW] `lib/features/profile/presentation/widgets/bmr_tdee_card.dart`
  * [NEW] `lib/features/profile/presentation/widgets/target_macros_card.dart`
  * [NEW] `lib/features/profile/presentation/widgets/user_info_card.dart`
  * [NEW] `lib/features/profile/presentation/widgets/edit_profile_bottom_sheet.dart`
  * [NEW] `lib/features/profile/presentation/screens/profile_screen.dart`
  * [MODIFY] `lib/features/home/presentation/screens/home_screen.dart` (Replace Profile placeholder tab with `ProfileScreen()`)
  * [MODIFY] `lib/core/router/app_router.dart` (Add `/profile` route)
  * [NEW] `test/features/profile/presentation/profile_screen_test.dart`
* **Tasks**:
  1. `ProfileHeaderCard`: Displays user avatar, display name, goal pill badge (`Muscle Gain`, `Fat Loss`, `Maintenance`), and edit trigger.
  2. `BmrTdeeCard`: Displays dual metric cards for BMR (kcal/day) and TDEE (kcal/day) + Target Calories banner (`AppColors.calories`).
  3. `TargetMacrosCard`: Displays target Protein (`#2563EB`), Carbs (`#D97706`), and Fat (`#059669`) goals with visual progress bars.
  4. `UserInfoCard`: Displays list tiles for Age, Height (cm), Weight (kg), Gender, and Activity Level.
  5. `EditProfileBottomSheet`: Mobile modal form with numeric input fields, gender segmented button, activity level chips, and primary goal chips.
  6. `ProfileScreen`: Scrollable mobile screen combining all cards, with pull-to-refresh (`RefreshIndicator`).
  7. Update `HomeScreen` and `app_router.dart`.
  8. Write widget tests for `ProfileScreen`.

---

### Phase 4: Verification & Quality Assurance
* **Goal**: Verify zero formatting or static analysis issues and ensure all unit/widget tests pass.
* **Tasks**:
  1. `dart format --output=none --set-exit-if-changed .`
  2. `flutter analyze`
  3. `flutter test`
