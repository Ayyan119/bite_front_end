# Feature Implementation Plan: 02 - Authentication & User Sessions

**Target Feature**: Authentication & User Sessions  
**Branch Name**: `feature/02-authentication-user-sessions`  
**Specification Reference**: [`specs/02_authentication_user_sessions.md`](file:///home/jiggra/BiteFrontEnd/specs/02_authentication_user_sessions.md)  
**Theme**: Light Theme (Fresh Emerald Green, Citrus Orange, Soft Mint, Light Slate, Crisp White)  

---

## 📋 Executive Summary

This implementation plan breaks down the development of **Feature 02: Authentication & User Sessions** into 6 clear, sequential, non-breaking execution steps. All work strictly adheres to the project's architectural guidelines (Riverpod state management, Repository pattern, feature-first structure, GoRouter guards) and visual design system.

---

## 🎯 Step-by-Step Implementation Roadmap

### Step 1: Data Layer Implementation (`lib/features/auth/data/`)
* **Goal**: Implement HTTP communication with backend auth endpoints and session persistence orchestration.
* **Tasks**:
  1. Create `AuthRemoteDataSource` in `lib/features/auth/data/datasources/auth_remote_data_source.dart`:
     - Method `login(LoginRequestModel request)` -> `POST /api/v1/auth/login`
     - Method `register(RegisterRequestModel request)` -> `POST /api/v1/auth/register`
     - Method `devToken(DevTokenRequestModel request)` -> `POST /api/v1/auth/dev-token`
  2. Create `AuthRepository` interface and `AuthRepositoryImpl` in `lib/features/auth/data/repositories/auth_repository.dart`:
     - Coordinate remote data calls via `AuthRemoteDataSource`.
     - Persist `access_token`, `user_id`, `email`, and `display_name` via `StorageService`.
     - Implement `restoreSession()` to read saved credentials on boot.
     - Implement `logout()` to wipe stored tokens via `StorageService.clearAll()`.
  3. Define Riverpod providers for `authRemoteDataSourceProvider` and `authRepositoryProvider`.

---

### Step 2: State Management & Notifier (`lib/features/auth/presentation/providers/`)
* **Goal**: Provide reactive, lifecycle-aware authentication state across the application using Riverpod `AsyncNotifier`.
* **Tasks**:
  1. Create `AuthNotifier` extending `AsyncNotifier<AuthResponseModel?>` in `lib/features/auth/presentation/providers/auth_provider.dart`.
  2. Implement state logic:
     - `build()`: Calls `authRepository.restoreSession()` asynchronously to initialize session on boot.
     - `login(String email, String password)`: Sets loading, calls repository, updates state with user session or sets error.
     - `register(RegisterRequestModel request)`: Handles user signup and session initialization.
     - `devToken(String email, String? userId)`: Handles rapid developer bypass login.
     - `logout()`: Clears storage and sets state to `AsyncValue.data(null)`.
  3. Export `authNotifierProvider`.

---

### Step 3: Declarative Router & Auth Guards (`lib/core/router/app_router.dart`)
* **Goal**: Seamlessly redirect users between public auth screens (`/login`, `/register`) and protected application screens (`/home`) based on `authNotifierProvider` state.
* **Tasks**:
  1. Update `app_router.dart` to watch `authNotifierProvider`.
  2. Add `redirect` callback:
     - Allow `/` splash screen while state is loading.
     - Redirect unauthenticated users navigating to protected routes (`/home`, etc.) to `/login`.
     - Redirect authenticated users attempting to view `/login` or `/register` to `/home`.
  3. Add GoRoute definitions for `/login` and `/register`.

---

### Step 4: UI Presentation Layer & Screens (`lib/features/auth/presentation/`)
* **Goal**: Build accessible, responsive Light Theme UI components with vibrant health/food aesthetics.
* **Tasks**:
  1. **Widgets**:
     - `DevTokenDialog` (`lib/features/auth/presentation/widgets/dev_token_dialog.dart`): Quick developer email input dialog.
     - `RegisterStepAccount` (`lib/features/auth/presentation/widgets/register_step_account.dart`): Step 1 - Email, password, display name inputs.
     - `RegisterStepBody` (`lib/features/auth/presentation/widgets/register_step_body.dart`): Step 2 - Age, gender selection chips, height, weight.
     - `RegisterStepGoals` (`lib/features/auth/presentation/widgets/register_step_goals.dart`): Step 3 - Activity level & primary goal cards with colorful icon badges.
  2. **Screens**:
     - `LoginScreen` (`lib/features/auth/presentation/screens/login_screen.dart`): Clean card layout, Bite logo, email/password text fields, emerald primary button, citrus dev login button, sign up link.
     - `RegisterScreen` (`lib/features/auth/presentation/screens/register_screen.dart`): Multi-step form container with top step progress bar, smooth step transitions, validation handling, submit button.

---

### Step 5: Unit, State & Widget Testing (`test/features/auth/`)
* **Goal**: Ensure robustness, error handling, state correctness, and regression testing.
* **Tasks**:
  1. **Data & Repository Unit Tests**:
     - Test `AuthRemoteDataSource` Dio request payload building and response parsing.
     - Test `AuthRepository` token persistence and failure mapping (`ServerFailure`, `UnauthorizedFailure`).
  2. **Notifier State Unit Tests**:
     - Test `AuthNotifier` initial restoration, login success state, login failure state, and logout clearing.
  3. **Widget & Form Tests**:
     - Test `LoginScreen` form validation and button tap actions.
     - Test `RegisterScreen` step progression (Step 1 -> 2 -> 3).

---

### Step 6: Code Formatting, Static Analysis & Verification
* **Goal**: Maintain strict code quality and ensure zero analyzer warnings.
* **Tasks**:
  1. Execute `dart format .` across the codebase.
  2. Execute `flutter analyze` to verify clean analysis without errors or warnings.
  3. Verify test suite passes via `flutter test`.

---

## 🎨 Light Theme & Visual Design Palette

| Element | Color Code | Visual Role |
| :--- | :--- | :--- |
| **Primary Accent** | `#10B981` (Emerald Mint) | Primary buttons, active step indicators, focus rings |
| **Secondary Accent** | `#F97316` (Citrus Orange) | Quick Dev Login button, energy highlights, calorie badges |
| **Container Light** | `#D1FAE5` (Mint Container) | Selected chip backgrounds, success alert badges |
| **Background** | `#F8FAFC` (Light Slate) | Global app screen background |
| **Surface Cards** | `#FFFFFF` (Crisp White) | Card containers, form inputs, dialog windows |
| **Text Primary** | `#0F172A` (Deep Slate) | Headings, form input text, active labels |
| **Text Secondary** | `#64748B` (Muted Slate) | Subtitles, field labels, placeholder text |
| **Error / Alert** | `#EF4444` (Warm Red) | Form validation errors, failed auth banners |

---

## ⚙️ Verification Checklist

- [ ] All 3 endpoints (`/auth/login`, `/auth/register`, `/auth/dev-token`) integrated into `AuthRemoteDataSource`.
- [ ] Token & user data correctly stored in `StorageService` upon successful authentication.
- [ ] Session restoration reads saved JWT token on app launch.
- [ ] `AuthNotifier` state updates correctly with `AsyncValue<AuthResponseModel?>`.
- [ ] GoRouter redirects unauthenticated users to `/login` and authenticated users to `/home`.
- [ ] `LoginScreen` and multi-step `RegisterScreen` built exclusively using Light Theme with vibrant food/health colors.
- [ ] `flutter analyze` passes with zero errors or warnings.
- [ ] `dart format .` applied cleanly.
