# Feature Specification: Task 05 - Real-Time SSE AI Nutrition Assistant

## 1. Overview & Goal

The **Real-Time SSE AI Nutrition Assistant** feature provides an interactive, conversational AI interface powered by the backend LangGraph Workflow 2 Agent streamed over **Server-Sent Events (SSE)** (`text/event-stream`).

### Key Objectives:
* **Low-Latency Streaming Interaction**: Enable real-time response rendering (<10ms Time-To-First-Token) with live status indicators during prompt processing.
* **Conversational AI Nutrition Intelligence**: Support asking nutrition advice, logging meals through natural language chat prompts ("I ate 300g chicken biryani for lunch"), querying daily macro balances, and receiving personalized recommendations.
* **Session Management**: Full support for listing, creating, selecting, switching between, and deleting multi-session chat histories.
* **Responsive Markdown & Rich UI**: Render Markdown-formatted AI responses with rich formatting (lists, bold text, macro tables, code blocks) and real-time status banners adhering to the project's Emerald Design System (`GoogleFonts.inter`, `#10B981` primary accents).

---

## 2. API & Data Contracts

All endpoints are prefixed with the base API URL `http://13.51.160.123:8000/api/v1` and require `Authorization: Bearer <access_token>`.

### 2.1 Real-Time SSE Stream Chat (`POST /chat`)
* **Path**: `/api/v1/chat`
* **Method**: `POST`
* **Content-Type**: `application/json`
* **Accept**: `text/event-stream`
* **Request Body** (`ChatRequestModel`):
  ```json
  {
    "message": "I ate 300g chicken biryani for lunch",
    "conversation_id": "c1f7b8e0-1234-4567-89ab-cdef01234567",
    "client_timezone": "Asia/Karachi"
  }
  ```
* **SSE Stream Event Protocol**:
  1. `event: status` — Processing status update from backend agent.
     ```http
     event: status
     data: {"status": "processing_prompt", "message": "Analyzing prompt and loading session memory..."}
     ```
  2. `event: message` — Streamed content token chunk.
     ```http
     event: message
     data: {"content": "I have logged your "}
     ```
  3. `event: done` — Stream completion event.
     ```http
     event: done
     data: {"conversation_id": "c1f7b8e0-1234-4567-89ab-cdef01234567", "status": "completed"}
     ```

### 2.2 List User Chat Sessions (`GET /chat/sessions`)
* **Path**: `/api/v1/chat/sessions`
* **Method**: `GET`
* **Response** (`List[ChatSessionResponseModel]`):
  ```json
  [
    {
      "id": "c1f7b8e0-1234-4567-89ab-cdef01234567",
      "user_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "title": "Lunch Logging: Chicken Biryani",
      "created_at": "2026-08-25 10:00:00+00",
      "updated_at": "2026-08-25 10:05:00+00",
      "message_count": 4
    }
  ]
  ```

### 2.3 Create Chat Session (`POST /chat/sessions`)
* **Path**: `/api/v1/chat/sessions`
* **Method**: `POST`
* **Request Body** (`CreateSessionRequestModel`): `{"title": "Custom Session Title"}`
* **Response**: `ChatSessionResponseModel` (Status `201 Created`).

### 2.4 Get Messages for a Session (`GET /chat/sessions/{session_id}/messages`)
* **Path**: `/api/v1/chat/sessions/{session_id}/messages`
* **Method**: `GET`
* **Response** (`List[ChatMessageResponseModel]`):
  ```json
  [
    {
      "id": "m1f7b8e0-1234-4567-89ab-cdef01234567",
      "session_id": "c1f7b8e0-1234-4567-89ab-cdef01234567",
      "role": "user",
      "content": "I ate 300g chicken biryani for lunch",
      "created_at": "2026-08-25 10:00:00+00"
    },
    {
      "id": "m2f7b8e0-1234-4567-89ab-cdef01234567",
      "session_id": "c1f7b8e0-1234-4567-89ab-cdef01234567",
      "role": "assistant",
      "content": "Logged 300g Chicken Biryani (480 kcal, 28g protein).",
      "created_at": "2026-08-25 10:00:05+00"
    }
  ]
  ```

### 2.5 Delete Chat Session (`DELETE /chat/sessions/{session_id}`)
* **Path**: `/api/v1/chat/sessions/{session_id}`
* **Method**: `DELETE`
* **Response**: `{"status": "deleted", "session_id": "c1f7b8e0-1234-4567-89ab-cdef01234567"}`

---

## 3. Layered Architecture Breakdown

```text
lib/
├── core/
│   └── network/
│       └── sse_client.dart                     # SSE stream line parser & event transformer using Dio/http byte streams
└── features/
    └── chat/
        ├── data/
        │   ├── datasources/
        │   │   └── chat_remote_data_source.dart # REST API endpoints + SSE HTTP stream requester
        │   ├── models/
        │   │   ├── chat_request_model.dart     # ChatRequestModel & CreateSessionRequestModel (Existing)
        │   │   ├── chat_session_response_model.dart # ChatSessionResponseModel (Existing)
        │   │   ├── chat_message_response_model.dart # ChatMessageResponseModel (Existing)
        │   │   └── sse_event_model.dart        # Stream events (SseStatusEvent, SseTokenEvent, SseDoneEvent, SseErrorEvent)
        │   └── repositories/
        │       └── chat_repository.dart        # Implementation isolating SSE stream connection & REST API requests
        ├── domain/
        │   ├── entities/
        │   │   ├── chat_session.dart           # Domain entity for sessions
        │   │   └── chat_message.dart           # Domain entity for messages
        │   └── repositories/
        │       └── chat_repository_interface.dart # Optional repository interface
        └── presentation/
            ├── providers/
            │   ├── chat_sessions_provider.dart # AsyncNotifier managing list of active user chat sessions
            │   └── active_chat_provider.dart   # StateNotifier managing streaming, active session, & message list
            ├── screens/
            │   └── chat_screen.dart            # Main chat interface with responsive drawer / split pane
            └── widgets/
                ├── chat_bubble.dart            # Markdown message rendering bubble with user vs AI styling
                ├── chat_input_bar.dart         # Prompt text input field with send button & loading state
                ├── sse_status_banner.dart      # Real-time status indicator pill ("Analyzing prompt...")
                └── chat_sessions_drawer.dart   # Drawer / Sidebar listing past chat sessions with delete action
```

---

## 4. State Management Design

### 4.1 Stream Event Data Structure (`SseEvent`)
```dart
sealed class SseEvent {
  const SseEvent();
}

class SseStatusEvent extends SseEvent {
  final String status;
  final String message;
  const SseStatusEvent({required this.status, required this.message});
}

class SseTokenEvent extends SseEvent {
  final String content;
  const SseTokenEvent({required this.content});
}

class SseDoneEvent extends SseEvent {
  final String conversationId;
  final String status;
  const SseDoneEvent({required this.conversationId, required this.status});
}

class SseErrorEvent extends SseEvent {
  final String error;
  const SseErrorEvent({required this.error});
}
```

### 4.2 Active Chat State Model (`ActiveChatState`)
```dart
enum StreamStatus { idle, connecting, streaming, error }

class ActiveChatState {
  final String? activeSessionId;
  final List<ChatMessageResponseModel> messages;
  final String currentStreamingResponse;
  final String? statusMessage;
  final StreamStatus streamStatus;
  final String? errorMessage;

  const ActiveChatState({
    this.activeSessionId,
    this.messages = const [],
    this.currentStreamingResponse = '',
    this.statusMessage,
    this.streamStatus = StreamStatus.idle,
    this.errorMessage,
  });

  ActiveChatState copyWith({
    String? activeSessionId,
    List<ChatMessageResponseModel>? messages,
    String? currentStreamingResponse,
    String? statusMessage,
    StreamStatus? streamStatus,
    String? errorMessage,
  });
}
```

### 4.3 Riverpod Providers
* `chatRepositoryProvider`: Supplies `ChatRepository` instance.
* `chatSessionsProvider`: `AsyncNotifierProvider<ChatSessionsNotifier, List<ChatSessionResponseModel>>`
  * Methods: `fetchSessions()`, `createSession(String title)`, `deleteSession(String id)`.
* `activeChatNotifierProvider`: `StateNotifierProvider<ActiveChatNotifier, ActiveChatState>`
  * Methods:
    * `loadSession(String sessionId)`: Fetches past messages from backend GET `/chat/sessions/{id}/messages`.
    * `sendMessage(String prompt)`:
      1. Adds optimistic `user` message to `messages`.
      2. Initiates SSE stream via `ChatRepository.streamChat()`.
      3. Sets `streamStatus` to `connecting`.
      4. Updates `statusMessage` on receiving `SseStatusEvent`.
      5. Appends token to `currentStreamingResponse` on `SseTokenEvent` (sets `streamStatus` to `streaming`).
      6. Commits accumulated response to `messages` as `assistant` role on `SseDoneEvent`, clears streaming buffer, updates `activeSessionId`, and refreshes `chatSessionsProvider`.
    * `startNewSession()`: Resets `activeSessionId` to `null` and clears active message feed for a fresh conversation.

---

## 5. UI & Responsive Layout Guidelines

Aligned with the project design reference ([DESIGN_REFERENCE.md](file:///home/jiggra/BiteFrontEnd/DESIGN_REFERENCE.md)):
* **Color Palette**: Emerald primary green (`#10B981`), neutral light/dark surface card background, soft shadows, rounded corners (`AppRadius.lg` / 16px).
* **Typography**: Clean sans-serif hierarchy matching `GoogleFonts.inter`.

### 5.1 Chat Screen Layout
* **Mobile Layout**:
  * AppBar with session title and Hamburger icon opening `ChatSessionsDrawer`.
  * Message feed rendered with `ListView.builder` auto-scrolling to the bottom as tokens arrive.
  * `SseStatusBanner`: Animated pill badge above input bar when `statusMessage` is active (e.g. *"Analyzing prompt and loading session memory..."*).
  * `ChatInputBar`: Rounded text input (`AppRadius.full`), send button with Emerald primary color (`#10B981`), disabled during streaming.
* **Tablet / Desktop Layout**:
  * Permanent left sidebar drawer (`ChatSessionsDrawer`, width ~280px).
  * Main chat view filling remaining space.

### 5.2 Message Formatting & Cards
* **User Message Bubble**: Aligned right, rounded corners with sharp bottom-right, filled with primary emerald color (`#10B981`), white text.
* **Assistant Message Bubble**: Aligned left, rounded corners with sharp top-left, `surfaceVariant` background color, Markdown rendering (`flutter_markdown`) supporting list items, bold headers, and macro summary tables.

---

## 6. Testing & Verification Checklist

### 6.1 Unit Tests
* **`SseClientTest`**: Test line-by-line parsing of raw SSE streams (`event: status\ndata: ...\n\n`, `event: message`, `event: done`).
* **`ChatRepositoryTest`**: Verify error handling, timeout recovery, and HTTP stream token conversion.
* **`ActiveChatNotifierTest`**: Verify state transitions (`idle` → `connecting` → `streaming` → `idle`), token concatenation, and history updating.

### 6.2 Widget Tests
* **`ChatBubbleTest`**: Test markdown rendering for assistant messages and styling for user messages.
* **`ChatInputBarTest`**: Test prompt submission, empty text validation, and disabled state while streaming.
* **`ChatScreenTest`**: Test layout switching (mobile drawer vs tablet split pane) and session selection.

### 6.3 Static Analysis & Code Quality
```bash
# Code formatting check
dart format --output=none --set-exit-if-changed .

# Static analysis
flutter analyze
```
