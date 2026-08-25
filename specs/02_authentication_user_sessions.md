# Feature Specification: Authentication & User Sessions

**Feature Branch**: `feature/02-authentication-user-sessions`  
**Specification Path**: `specs/02_authentication_user_sessions.md`  
**Target Milestone**: Phase 2 - Feature 1: Authentication & User Sessions  
**Theme & Aesthetics**: Light Theme only, featuring fresh, vibrant, natural food & health colors (Emerald Mint, Warm Citrus, Crisp Clean White, Light Slate).

---

## 1. Overview & Goal

The **Authentication & User Sessions** feature provides end-to-end user authentication, session persistence, token lifecycle management, and router redirection guards for the **Bite Frontend** application.

### Key Objectives:
1. **User Authentication**: Support user login via email/password (`POST /auth/login`), user registration with physical profile parameters (`POST /auth/register`), and rapid developer authentication (`POST /auth/dev-token`).
2. **Session Persistence & Restoration**: Automatically restore saved access tokens and user credentials from `StorageService` on app boot up, maintaining seamless user login state across app restarts.
3. **State Management**: Implement a Riverpod `AuthNotifier` managing an `AsyncValue<AuthResponseModel?>` state with clear loading, success, and user-friendly error states.
4. **Declarative Router Guards**: Protect core application routes (`/home`, `/dashboard`, `/profile`, `/meals`, `/chat`) via GoRouter `redirect` logic based on authentication status.
5. **Fresh Light Theme UI**: Build cohesive, accessible Material 3 screens (`LoginScreen`, multi-step `RegisterScreen`, and `DevTokenDialog`) adopting a vibrant **Light Theme** with natural food and health color accents (Emerald `#10B981`, Citrus Orange `#F97316`, Amber `#F59E0B`, Soft Mint `#D1FAE5`, Crisp White `#FFFFFF`).

---

## 2. API & Data Contracts

All authentication requests target the FastAPI backend base URL (`http://13.51.160.123:8000/api/v1`).

### 2.1 Endpoint Specifications

#### 1. Login Endpoint
* **HTTP Method**: `POST`
* **Path**: `/api/v1/auth/login`
* **Auth Required**: No
* **Headers**: `Content-Type: application/json`, `Accept: application/json`
* **Request DTO (`LoginRequestModel`)**:
  ```json
  {
    "email": "user@example.com",
    "password": "user_password"
  }
  ```
* **Response DTO (`AuthResponseModel` - `200 OK`)**:
  ```json
  {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "bearer",
    "expires_in": 86400,
    "user_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "email": "user@example.com",
    "display_name": "User Name",
    "age": 28,
    "height_cm": 178.0,
    "weight_kg": 75.0,
    "gender": "male",
    "bmr": 1720.0,
    "tdee": 2666.0,
    "target_calories": 2400.0
  }
  ```

#### 2. User Registration Endpoint
* **HTTP Method**: `POST`
* **Path**: `/api/v1/auth/register`
* **Auth Required**: No
* **Headers**: `Content-Type: application/json`, `Accept: application/json`
* **Request DTO (`RegisterRequestModel`)**:
  ```json
  {
    "email": "newuser@example.com",
    "password": "secret_password",
    "display_name": "New User",
    "age": 25,
    "height_cm": 175.0,
    "weight_kg": 70.0,
    "gender": "male",
    "activity_level": "moderate",
    "primary_goal": "muscle_gain"
  }
  ```
* **Enums**:
  - `gender`: `male` | `female` | `other`
  - `activity_level`: `sedentary` | `light` | `moderate` | `active` | `very_active`
  - `primary_goal`: `weight_loss` | `maintenance` | `muscle_gain`
* **Response DTO (`AuthResponseModel` - `201 Created`)**: Same schema as `/auth/login`.

#### 3. Development JWT Token Generator Endpoint
* **HTTP Method**: `POST`
* **Path**: `/api/v1/auth/dev-token`
* **Auth Required**: No
* **Headers**: `Content-Type: application/json`, `Accept: application/json`
* **Request DTO (`DevTokenRequestModel`)**:
  ```json
  {
    "email": "alex.morgan@bite.app",
    "user_id": null
  }
  ```
* **Response DTO (`AuthResponseModel` - `200 OK`)**: Same schema as `/auth/login`.

---

## 3. Layered Architecture Breakdown

Following the project's **Feature-First Lightweight Architecture** guidelines:

```text
lib/features/auth/
├── data/
│   ├── datasources/
│   │   └── auth_remote_data_source.dart        # Dio HTTP requests (/auth/login, /auth/register, /auth/dev-token)
│   ├── models/
│   │   ├── auth_response_model.dart             # DTO for auth token & user summary
│   │   ├── login_request_model.dart            # DTO for login credentials
│   │   ├── register_request_model.dart         # DTO for user sign up payload
│   │   └── dev_token_request_model.dart        # DTO for dev token bypass
│   └── repositories/
│       └── auth_repository.dart                 # Orchestrates remote data calls and StorageService persistence
├── presentation/
│   ├── providers/
│   │   └── auth_provider.dart                   # AuthNotifier (AsyncNotifierProvider<AuthNotifier, AuthResponseModel?>)
│   ├── screens/
│   │   ├── login_screen.dart                    # Email/password form & quick dev login entry
│   │   └── register_screen.dart                 # Multi-step sign-up workflow screen
│   └── widgets/
│       ├── dev_token_dialog.dart                # Quick developer login modal
│       ├── register_step_account.dart           # Step 1: Email, Password, Name
│       ├── register_step_body.dart              # Step 2: Age, Gender, Height, Weight
│       └── register_step_goals.dart             # Step 3: Activity level, Primary goal
```

---

## 4. State Management Design

### 4.1 `AuthNotifier` State Definition

The primary authentication state will be managed by `AuthNotifier` using Riverpod's `AsyncNotifier`:

```dart
class AuthNotifier extends AsyncNotifier<AuthResponseModel?> {
  @override
  FutureOr<AuthResponseModel?> build() async {
    // Session Restoration on App Initialization
    return ref.read(authRepositoryProvider).restoreSession();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).login(email: email, password: password)
    );
  }

  Future<void> register(RegisterRequestModel request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).register(request)
    );
  }

  Future<void> devToken({required String email, String? userId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).devToken(email: email, userId: userId)
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }
}
```

### 4.2 Storage & Session Persistence Flow

1. **Successful Auth Response**:
   - `AuthRepository` receives `AuthResponseModel`.
   - `StorageService.saveToken(response.accessToken)` stores the Bearer token securely.
   - `StorageService.saveUserData(...)` stores `user_id`, `email`, and `display_name`.
2. **Session Restoration (`restoreSession()`)**:
   - On app boot, `StorageService.getToken()` is read.
   - If token exists and is valid, `AuthRepository` loads stored user data and populates `AuthResponseModel`.
   - If token is missing or expired, `restoreSession()` returns `null`.
3. **Session Expiry / Logout**:
   - Calling `logout()` or encountering `401 Unauthorized` via `AuthInterceptor` triggers `StorageService.clearAll()` and resets `AuthNotifier` state to `AsyncValue.data(null)`.

### 4.3 Declarative Routing Guards (`app_router.dart`)

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: RiverpodListenable(ref, authNotifierProvider),
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register';

      if (isLoading) return null; // Let splash screen render

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && (isAuthRoute || state.matchedLocation == '/')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
});
```

---

## 5. UI & Light Theme Guidelines (Colorful, Natural & Health Palette)

### 5.1 Color Scheme & Visual Identity
The app uses a **Light Theme** exclusively, with vibrant colors inspired by fresh whole foods, natural greens, and energy citrus:
* **Background**: Light slate/porcelain (`AppColors.lightBackground` = `#F8FAFC`).
* **Surface & Cards**: Pure crisp white (`AppColors.lightSurface` = `#FFFFFF`) with subtle soft shadows (`0px 4px 12px rgba(16, 185, 129, 0.06)`).
* **Primary Brand Accent**: Fresh Emerald Mint (`AppColors.primary` = `#10B981`) & Mint Soft Container (`#D1FAE5`).
* **Secondary Energy Accent**: Citrus Orange (`AppColors.secondary` = `#F97316`) for secondary CTAs and highlights.
* **Health & Macro Accents**:
  - Calorie Orange (`#F97316`)
  - Protein Ocean Blue (`#3B82F6`)
  - Carbs Sun Yellow (`#F59E0B`)
  - Fat Avocado Green (`#10B981`)
* **Typography**: Deep slate primary text (`#0F172A`), muted slate secondary text (`#64748B`), leveraging `GoogleFonts.inter()`.

### 5.2 Responsive Layout & Screen Specs

#### 1. `LoginScreen`
* **Background & Layout**: Light slate background (`#F8FAFC`) with centered responsive constraint container (`maxWidth: 480`).
* **Header**: Elevated `BiteLogo` widget with a gradient mint/emerald ring, sub-caption: *"Intelligent Nutrition & Vision Macro Tracking"*.
* **Card Container**: White rounded card (`borderRadius: 24`, border `#E2E8F0`) containing:
  - Email field (`TextInputType.emailAddress`) with a leaf/person leading icon and emerald focus outline.
  - Password field (`obscureText: true`) with key icon and toggleable visibility icon.
  - Error alert badge: Warm red container (`#FEE2E2`) with red text (`#EF4444`) when login fails.
* **Actions**:
  - Primary **"Log In"** button: Full width, vibrant emerald fill (`#10B981`), white text, rounded corners (`borderRadius: 16`), with loading spinner when submitting.
  - Secondary **"⚡ Dev Quick Login"** pill button: Citrus orange outline with orange icon (`#F97316`) for instant developer bypass dialog.
  - Footer link: *"New to Bite? **Create an account**"* in emerald bold link text.

#### 2. `RegisterScreen` (Multi-Step Form)
* **Background & Layout**: Light slate background with top app bar step indicator.
* **Step Header**: Step progress bar (3 steps) rendered with colorful rounded pills:
  - Active step: Emerald Green (`#10B981`)
  - Completed step: Mint Light (`#A7F3D0`)
  - Pending step: Light Gray (`#E2E8F0`)
* **Step 1: Account Setup**: Email, Password, Display Name.
* **Step 2: Physical Profile**: Age, Gender (segmented chips: Male, Female, Other in mint/emerald selection state), Height (cm), Weight (kg).
* **Step 3: Lifestyle & Goal**:
  - Activity Level choices: Styled cards with icons (Sedentary 🛋️, Light 🚶, Moderate 🏃, Active 🚴, Very Active 🏋️).
  - Primary Goal choices: Styled cards (Weight Loss 📉 in Citrus Orange, Maintenance ⚖️ in Sun Yellow, Muscle Gain 📈 in Ocean Blue).
* **Navigation Buttons**: "Back" outlined button, "Next" / "Complete Sign Up" filled emerald button.

#### 3. `DevTokenDialog`
* **Modal Dialog**: Crisp white dialog card with rounded corners (`28.0`), featuring an electric citrus icon, quick email selection/input, and instant token generation button.

---

## 6. Testing & Verification Checklist

### 6.1 Unit & Data Layer Verification
- [ ] **Data Source Tests**: Verify `AuthRemoteDataSource` calls `/auth/login`, `/auth/register`, and `/auth/dev-token` with correct headers & Dio options.
- [ ] **Repository Tests**: Verify `AuthRepository` saves JWT tokens to `StorageService` upon successful response and handles API failures by throwing appropriate `Failure` objects (`ServerFailure`, `UnauthorizedFailure`).

### 6.2 State & Provider Verification
- [ ] **AuthNotifier Unit Tests**: Test initial state loading, successful login state update, failed login error state, and session cleanup on logout.
- [ ] **Session Restoration Tests**: Mock `StorageService` with a valid token and verify `AuthNotifier` boots directly into `AsyncValue.data(AuthResponseModel)`.

### 6.3 UI & Router Verification
- [ ] **Widget Tests**:
  - `LoginScreen`: Verify text field rendering, validation error messages on empty submission, light theme colors, and navigation link clicks.
  - `RegisterScreen`: Verify step transitions (Step 1 -> Step 2 -> Step 3) and registration payload dispatch.
- [ ] **Router Guard Tests**: Verify unauthenticated users are redirected from `/home` to `/login`, and authenticated users are redirected from `/login` to `/home`.

### 6.4 Static Analysis & Formatting
- [ ] Run formatting check: `dart format .`
- [ ] Run static analyzer: `flutter analyze`
