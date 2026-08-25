# Implementation Plan: Task 05 - Real-Time SSE AI Nutrition Assistant

## Overview
This implementation plan outlines the step-by-step technical roadmap for building the **Real-Time SSE AI Nutrition Assistant** feature in the Bite Flutter Application, based on the feature specification in [specs/05_real_time_sse_ai_nutrition_assistant.md](file:///home/jiggra/BiteFrontEnd/specs/05_real_time_sse_ai_nutrition_assistant.md).

No production code modifications will be executed in this step; this plan details the architecture, file creation sequence, and verification protocol.

---

## 🏗 Architecture & Dependencies

```text
lib/
├── core/
│   └── network/
│       └── sse_client.dart                     # SSE stream line parser & event transformer
└── features/
    └── chat/
        ├── data/
        │   ├── datasources/
        │   │   └── chat_remote_data_source.dart # Dio HTTP REST + byte stream SSE requester
        │   ├── models/
        │   │   └── sse_event_model.dart        # Stream event hierarchy (Status, Token, Done, Error)
        │   └── repositories/
        │       └── chat_repository.dart        # Repository for chat operations & streaming
        └── presentation/
            ├── providers/
            │   ├── chat_sessions_provider.dart # AsyncNotifier managing user session list
            │   └── active_chat_provider.dart   # StateNotifier managing stream state & message feed
            ├── screens/
            │   └── chat_screen.dart            # Responsive chat interface screen
            └── widgets/
                ├── chat_bubble.dart            # User & Assistant markdown message bubbles
                ├── chat_input_bar.dart         # Prompt entry bar with send button & loading state
                ├── sse_status_banner.dart      # Real-time backend progress indicator pill
                └── chat_sessions_drawer.dart   # Session history drawer / sidebar panel
```

---

## 🗓 Sequential Implementation Roadmap

### Phase 1: Core Networking & SSE Stream Client (`lib/core/network/`)
* **Objective**: Create a robust Server-Sent Events (SSE) client that parses chunked HTTP responses into Dart objects.
* **Target File**: `lib/core/network/sse_client.dart`
* **Test File**: `test/core/network/sse_client_test.dart`
* **Tasks**:
  1. Implement `SseClient` to convert an incoming `Stream<List<int>>` or line stream into `Stream<SseEvent>`.
  2. Parse standard SSE line frames:
     * `event: status` + `data: {"status": "...", "message": "..."}`
     * `event: message` + `data: {"content": "..."}`
     * `event: done` + `data: {"conversation_id": "...", "status": "completed"}`
  3. Write comprehensive unit tests in `sse_client_test.dart` simulating incomplete line buffering and multi-byte stream chunks.

---

### Phase 2: Data Layer & Repository (`lib/features/chat/data/`)
* **Objective**: Define stream models and wire Dio HTTP REST & SSE streaming remote data source.
* **Target Files**:
  * `lib/features/chat/data/models/sse_event_model.dart`
  * `lib/features/chat/data/datasources/chat_remote_data_source.dart`
  * `lib/features/chat/data/repositories/chat_repository.dart`
* **Tasks**:
  1. Create `SseEvent` sealed class and event types (`SseStatusEvent`, `SseTokenEvent`, `SseDoneEvent`, `SseErrorEvent`).
  2. Build `ChatRemoteDataSource` with Dio:
     * `getSessions()` (`GET /api/v1/chat/sessions`)
     * `createSession(CreateSessionRequestModel)` (`POST /api/v1/chat/sessions`)
     * `getSessionMessages(String id)` (`GET /api/v1/chat/sessions/{id}/messages`)
     * `deleteSession(String id)` (`DELETE /api/v1/chat/sessions/{id}`)
     * `streamChat(ChatRequestModel)` (`POST /api/v1/chat`, `responseType: ResponseType.stream`)
  3. Build `ChatRepository` wrapping data source requests and attaching authentication interceptors.

---

### Phase 3: State Management & Riverpod Notifiers (`lib/features/chat/presentation/providers/`)
* **Objective**: Create state notifiers managing real-time chat streaming and session history list.
* **Target Files**:
  * `lib/features/chat/presentation/providers/chat_sessions_provider.dart`
  * `lib/features/chat/presentation/providers/active_chat_provider.dart`
  * `test/features/chat/presentation/providers/active_chat_provider_test.dart`
* **Tasks**:
  1. `chatSessionsProvider`: `AsyncNotifierProvider` to fetch, create, and delete sessions.
  2. `activeChatNotifierProvider`: `StateNotifierProvider` managing `ActiveChatState`:
     * `loadSession(String id)`: Loads message history from backend REST endpoint.
     * `sendMessage(String prompt)`:
       - Append optimistic `user` message to message list.
       - Set `streamStatus` to `connecting`.
       - Connect to SSE stream via `ChatRepository.streamChat()`.
       - Update `statusMessage` on `SseStatusEvent`.
       - Append token chunks to `currentStreamingResponse` on `SseTokenEvent`.
       - Finalize message on `SseDoneEvent`, move content into message feed, clear streaming buffer, and refresh session list.
     * `startNewSession()`: Resets current session state for fresh prompt.
  3. Write unit tests for provider state transitions.

---

### Phase 4: UI Screens & Responsive Components (`lib/features/chat/presentation/`)
* **Objective**: Design clean Emerald-themed UI matching [DESIGN_REFERENCE.md](file:///home/jiggra/BiteFrontEnd/DESIGN_REFERENCE.md).
* **Target Files**:
  * `lib/features/chat/presentation/widgets/chat_bubble.dart`
  * `lib/features/chat/presentation/widgets/chat_input_bar.dart`
  * `lib/features/chat/presentation/widgets/sse_status_banner.dart`
  * `lib/features/chat/presentation/widgets/chat_sessions_drawer.dart`
  * `lib/features/chat/presentation/screens/chat_screen.dart`
* **Tasks**:
  1. `ChatBubble`: Render user message (Emerald `#10B981` right bubble) and assistant message (left bubble with `flutter_markdown` formatting for bullet points, bold headers, and macro tables).
  2. `ChatInputBar`: Text input field, send button, disabled state while streaming.
  3. `SseStatusBanner`: Animated pill badge displaying active status (e.g. *"Analyzing prompt and loading session memory..."*).
  4. `ChatSessionsDrawer`: Responsive sidebar listing past chat sessions with creation and delete options.
  5. `ChatScreen`: Auto-scrolling list view, responsive layout switcher (Mobile drawer vs Tablet permanent 280px sidebar).

---

### Phase 5: Testing, Static Analysis & Verification
* **Objective**: Validate feature implementation against formatting, static analysis, and test suites.
* **Tasks**:
  1. `dart format --output=none --set-exit-if-changed .`
  2. `flutter analyze`
  3. Run unit & widget tests for chat stream parser, providers, and UI.
