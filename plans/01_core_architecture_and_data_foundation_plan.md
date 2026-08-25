# Implementation Plan: Phase 1 - Core Architecture & Data Foundation

**Specification Reference**: [`specs/01_core_architecture_and_data_foundation.md`](file:///home/jiggra/BiteFrontEnd/specs/01_core_architecture_and_data_foundation.md)  
**Target Branch**: `feature/01-core-architecture-and-data-foundation`  

---

## Goal Description

Establish the core architecture, state management, HTTP networking, persistent storage, error handling, and strongly typed DTO model baseline for the **Bite Frontend** application. This foundation enables seamless data flow between Riverpod state providers, local encrypted/key-value storage, and the live FastAPI backend (`http://13.51.160.123:8000/api/v1`).

---

## User Review Required

> [!IMPORTANT]
> **Dependency Addition**: We will add `shared_preferences: ^2.5.2` to `pubspec.yaml` for persistent storage of tokens and user session data.
>
> **Lightweight Clean Architecture DTOs**: To avoid unnecessary `build_runner` code generation complexity and keep compilation fast, DTO models will utilize handwritten, robust `fromJson` / `toJson` factories with strict type casting and null safety.

---

## Open Questions

- *No unresolved open questions at this stage. Requirements match [`api_docs.md`](file:///home/jiggra/BiteFrontEnd/api_docs.md).*

---

## Proposed Changes

### Dependencies & Core Configuration

#### [MODIFY] `pubspec.yaml`
- Add `shared_preferences: ^2.5.2` under `dependencies`.

#### [NEW] `lib/core/constants/storage_constants.dart`
- Define keys:
  - `STORAGE_KEY_ACCESS_TOKEN = 'access_token'`
  - `STORAGE_KEY_USER_ID = 'user_id'`
  - `STORAGE_KEY_USER_EMAIL = 'user_email'`
  - `STORAGE_KEY_DISPLAY_NAME = 'display_name'`

---

### Errors & Failure Domain

#### [NEW] `lib/core/errors/exception.dart`
- Define `ServerException`, `CacheException`, `NetworkException`, `UnauthorizedException`.

#### [NEW] `lib/core/errors/failure.dart`
- Define base abstract `Failure` class with `message` and `statusCode`.
- Implement `ServerFailure`, `CacheFailure`, `NetworkFailure`, `UnauthorizedFailure`.

---

### Local Storage & Networking Layer

#### [NEW] `lib/core/utils/storage_service.dart`
- `StorageService` class backed by `SharedPreferences`.
- Methods:
  - `Future<void> saveToken(String token)`
  - `Future<String?> getToken()`
  - `Future<void> clearToken()`
  - `Future<void> saveUserData({required String userId, required String email, String? displayName})`
  - `Future<Map<String, String?>> getUserData()`
  - `Future<void> clearAll()`
- Expose `storageServiceProvider` via Riverpod.

#### [NEW] `lib/core/network/auth_interceptor.dart`
- Interceptor subclass overriding `onRequest` and `onError`:
  - `onRequest`: fetches token from `StorageService`; appends `Authorization: Bearer <access_token>` if non-null.
  - `onError`: if `statusCode == 401`, calls `StorageService.clearAll()` and handles unauthenticated state.

#### [MODIFY] `lib/core/network/dio_provider.dart`
- Attach `AuthInterceptor` (injected with `storageServiceProvider`) to the `Dio` instance alongside `LogInterceptor`.

---

### Core Feature DTO Models

#### [NEW] `lib/features/auth/data/models/login_request_model.dart` & `auth_response_model.dart`
- Models: `LoginRequestModel`, `RegisterRequestModel`, `DevTokenRequestModel`, `AuthResponseModel`.

#### [NEW] `lib/features/profile/data/models/user_profile_response_model.dart`
- Models: `UserProfileResponseModel`, `UserProfileUpdateModel`.

#### [NEW] `lib/features/dashboard/data/models/daily_dashboard_response_model.dart`
- Models: `DailyDashboardResponseModel`, `MacroProgressModel`, `LoggedMealSummaryModel`, `HistoricalAnalyticsResponseModel`, `DailyHistoryItemModel`.

#### [NEW] `lib/features/meals/data/models/meal_analysis_response_model.dart`
- Models: `MealAnalyzeRequestModel`, `MealAnalysisResponseModel`, `DetectedItemModel`, `MealConfirmRequestModel`, `MealConfirmResponseModel`.

#### [NEW] `lib/features/chat/data/models/chat_session_response_model.dart`
- Models: `ChatRequestModel`, `ChatSessionResponseModel`, `CreateSessionRequestModel`, `ChatMessageResponseModel`.

---

## Verification Plan

### Automated Tests
1. **Pub Get**: Run `flutter pub get`.
2. **Unit Tests**:
   - `test/core/storage_service_test.dart`: Test token save/get/clear operations.
   - `test/core/auth_interceptor_test.dart`: Test Bearer token injection and 401 error handling.
   - `test/core/dto_models_test.dart`: Test JSON deserialization and serialization for all 5 feature model clusters against `api_docs.md` payloads.
   - Run command: `flutter test`
3. **Static Analysis & Formatting**:
   - Run command: `dart format . && flutter analyze`

### Manual Verification
- Verify that `flutter analyze` reports 0 errors and 0 warnings.
