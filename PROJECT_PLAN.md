# Project Bite Frontend - Comprehensive Implementation Plan

This document outlines the detailed roadmap, feature breakdown, task dependencies, data models, state management, and implementation sequence for the **Bite Frontend** Flutter application based on the [Bite API Specification](file:///home/jiggra/BiteFrontEnd/api_docs.md).

---

## 🏗 Architectural Blueprint

Following the project's [Engineering & Architecture Guidelines](file:///home/jiggra/BiteFrontEnd/AGENTS.md):
* **Architecture**: Feature-first structure (`lib/features/<feature>/data,domain,presentation`)
* **State Management**: Riverpod (`flutter_riverpod`)
* **Navigation**: GoRouter (`go_router`) with auth redirect guards
* **Networking**: Dio (`dio`) with interceptors for Bearer Token and logging
* **UI & Theme**: Material 3 theme (`GoogleFonts.inter`), dynamic light/dark mode support, responsive screen constraints

```text
lib/
├── app.dart                                    # Root App widget (MaterialApp.router + Theme)
├── main.dart                                   # ProviderScope entrypoint
├── core/
│   ├── constants/
│   │   └── api_constants.dart                  # Base URL & API routes
│   ├── network/
│   │   ├── dio_provider.dart                   # Centralized Dio instance & interceptors
│   │   └── sse_client.dart                     # SSE stream parser for AI Chat
│   ├── router/
│   │   └── app_router.dart                     # GoRouter configuration & auth guards
│   ├── theme/
│   │   └── app_theme.dart                      # Light & Dark Material 3 theme
│   └── utils/
│       └── storage_service.dart                # Local storage for JWT auth tokens
└── features/
    ├── auth/                                   # Authentication & Dev Token
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── dashboard/                              # Daily Dashboard & Macro Analytics
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── meals/                                  # Camera/Image Vision Analysis & Meal Logging
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── chat/                                   # SSE Stream AI Nutrition Assistant & History
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── profile/                                # User Profile, BMR/TDEE & Macro Goals
        ├── data/
        ├── domain/
        └── presentation/
```

---

## 🗓 Detailed Implementation Phases

### Phase 1: Core Architecture & Data Foundation
* **Task 1.1: Local Storage & Token Persistence**
  - Implement `StorageService` for persisting `access_token` and user session info.
* **Task 1.2: Dio Auth Interceptor**
  - Update `dio_provider.dart` with an `AuthInterceptor` that attaches `Authorization: Bearer <token>` to protected requests and handles `401 Unauthorized` token expiration.
* **Task 1.3: Core Data Models & DTOs**
  - Define serializable models for API requests/responses (Auth, Profile, Meal, Dashboard, Chat).

---

### Phase 2: Feature 1 - Authentication & User Session (`/api/v1/auth`)
* **Endpoints**: `POST /auth/login`, `POST /auth/register`, `POST /auth/dev-token`
* **Task 2.1: Data Layer (`features/auth/data`)**
  - Create `AuthRemoteDataSource` using Dio.
  - Create `AuthRepository` to handle login, registration, dev-token request, and token storage.
* **Task 2.2: State Management (`features/auth/presentation/providers`)**
  - Create `authNotifierProvider` (`AsyncValue<UserModel?>`) with login, register, devToken, and logout methods.
* **Task 2.3: UI Screens (`features/auth/presentation/screens`)**
  - **Login Screen**: Clean form with email/password validation, quick-action "Dev Token" button for instant developer login, and register link.
  - **Register Screen**: Multi-step or comprehensive form capturing `email`, `password`, `display_name`, `age`, `height_cm`, `weight_kg`, `gender`, `activity_level`, `primary_goal`.
* **Task 2.4: Router Integration**
  - Configure GoRouter redirect guard based on `authNotifierProvider` state.

---

### Phase 3: Feature 2 - Daily Macro Dashboard & Analytics (`/api/v1/dashboard`)
* **Endpoints**: `GET /dashboard/daily?target_date=YYYY-MM-DD`, `GET /dashboard/history?days=30`
* **Task 3.1: Data Layer (`features/dashboard/data`)**
  - Models: `DailyDashboardResponse`, `MacroProgress`, `LoggedMealSummary`, `HistoricalAnalyticsResponse`.
  - Create `DashboardRemoteDataSource` and `DashboardRepository`.
* **Task 3.2: State Management (`features/dashboard/presentation/providers`)**
  - Create `dailyDashboardProvider(DateTime date)` family provider.
  - Create `historicalAnalyticsProvider(int days)` provider.
* **Task 3.3: UI Screens & Components (`features/dashboard/presentation`)**
  - **Daily Dashboard Screen**:
    - Header with date selector (Today, Previous/Next day navigation).
    - Calorie Progress Ring (Target vs Consumed vs Remaining).
    - Macro Breakdown Cards (Protein, Carbs, Fat progress bars with target/consumed metrics).
    - Today's Logged Meals Cards list with image thumbnail, calories, macro details.
    - Micronutrient Highlights summary.
  - **Analytics Screen**:
    - Multi-day calorie and macro intake trend charts (7/30/90 days).
    - Goal status indicators (under/on-target/over).

---

### Phase 4: Feature 3 - Multimodal Meal Ingestion & Vision Analysis (`/api/v1/meals`)
* **Endpoints**: `POST /meals/analyze` (JSON / Multipart Form), `POST /meals/confirm`
* **Task 4.1: Data Layer (`features/meals/data`)**
  - Models: `MealAnalyzeRequest`, `MealAnalysisResponse`, `DetectedItem`, `MealConfirmRequest`, `MealConfirmResponse`.
  - Create `MealRemoteDataSource` supporting image file upload (`FormData`) or URL string, caption, and meal type.
  - Create `MealRepository`.
* **Task 4.2: State Management (`features/meals/presentation/providers`)**
  - Create `mealAnalysisNotifierProvider` to manage analysis loading state, detected food items, portion adjustments, and confirmation flow.
* **Task 4.3: UI Screens & Components (`features/meals/presentation`)**
  - **Meal Logging Sheet / Camera Picker**:
    - Image selection (camera/gallery upload) + optional text caption input ("2 bananas with milk").
    - Meal type selection chips (`breakfast`, `lunch`, `dinner`, `snack`).
  - **Analysis Review & Confirmation Screen**:
    - Displays AI-detected food items with FDC match score.
    - Editable portion amount, unit, and calculated macros per item.
    - Add/remove items manually.
    - "Confirm & Log Meal" button with smooth commit to backend and immediate dashboard refresh.

---

### Phase 5: Feature 4 - Real-Time SSE AI Nutrition Assistant (`/api/v1/chat`)
* **Endpoints**: `POST /chat` (SSE `text/event-stream`), `GET /chat/sessions`, `POST /chat/sessions`, `GET /chat/sessions/{id}/messages`, `DELETE /chat/sessions/{id}`
* **Task 5.1: Core SSE Stream Client (`core/network/sse_client.dart`)**
  - Implement SSE parser handling `event: status`, `event: message`, and `event: done`.
* **Task 5.2: Data Layer (`features/chat/data`)**
  - Models: `ChatSession`, `ChatMessage`, `ChatRequest`, `SSEMessageChunk`.
  - Create `ChatRemoteDataSource` and `ChatRepository`.
* **Task 5.3: State Management (`features/chat/presentation/providers`)**
  - `chatSessionsProvider` for session list management and creation/deletion.
  - `activeChatNotifierProvider` managing message history and real-time streaming tokens.
* **Task 5.4: UI Screens & Components (`features/chat/presentation`)**
  - **Chat Interface**:
    - Chat bubble UI supporting streaming text, markdown formatting, and AI status indicators (e.g. *"Analyzing prompt and loading session memory..."*).
    - Message input bar with prompt submit.
  - **Sessions Drawer / Drawer List**:
    - Manage past chat sessions, search/filter history, delete session option.

---

### Phase 6: Feature 5 - User Profile & Goal Management (`/api/v1/profile`)
* **Endpoints**: `GET /profile`, `PUT /profile`
* **Task 6.1: Data Layer & State Management (`features/profile`)**
  - Models: `UserProfileResponse`, `UserProfileUpdate`.
  - `ProfileRepository` and `profileNotifierProvider`.
* **Task 6.2: UI Screens (`features/profile/presentation`)**
  - **Profile Screen**:
    - Displays user stats: Age, Height, Weight, Gender, Activity Level, Primary Goal.
    - Auto-calculated BMR, TDEE, Target Calories, Target Macros.
  - **Edit Profile Modal / Screen**:
    - Form to update metrics with real-time Mifflin-St Jeor re-calculation response from backend.

---

### Phase 7: App Shell, Navigation & Final Polish
* **Task 7.1: App Navigation Shell**
  - Implement bottom navigation bar (Mobile) / navigation rail (Tablet/Desktop) with tabs:
    1. **Dashboard**
    2. **Log Meal** (Quick Camera/Analysis modal)
    3. **AI Assistant** (Chat)
    4. **Profile**
* **Task 7.2: Error Handling & UX Polish**
  - Implement meaningful error dialogs, offline fallback indicators, empty states, and loading shimmers.
* **Task 7.3: Quality Assurance & Static Analysis**
  - Run `dart format .`, `flutter analyze`, and unit/widget tests for all providers and screens.

---

## 🎯 Implementation Roadmap Sequence

| Step | Module | Key Deliverable | Status |
|---|---|---|---|
| **1** | Core Foundation | Base setup, packages, themes, router & Dio | ✅ Completed |
| **2** | Storage & Models | Token storage, Auth & Profile DTO models | ⏳ Next |
| **3** | Auth Feature | Login, Register, Dev-Token screens & state | 🔲 Planned |
| **4** | Dashboard Feature | Daily summary screen, progress ring, macro bars | 🔲 Planned |
| **5** | Meal Vision Feature | Image/caption vision analysis & confirmation review | 🔲 Planned |
| **6** | SSE Chat Feature | Real-time SSE streaming AI assistant & sessions | 🔲 Planned |
| **7** | Profile Feature | BMR/TDEE viewer & physical metrics editor | 🔲 Planned |
| **8** | App Shell & Polish | Bottom navigation shell, responsive layout & tests | 🔲 Planned |
