import 'dart:async';
import 'package:bite_front_end/features/chat/data/models/chat_message_response_model.dart';
import 'package:bite_front_end/features/chat/data/models/chat_session_response_model.dart';
import 'package:bite_front_end/features/chat/data/models/sse_event_model.dart';
import 'package:bite_front_end/features/chat/data/repositories/chat_repository.dart';
import 'package:bite_front_end/features/chat/presentation/providers/chat_sessions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    bool clearActiveSession = false,
    List<ChatMessageResponseModel>? messages,
    String? currentStreamingResponse,
    String? statusMessage,
    bool clearStatusMessage = false,
    StreamStatus? streamStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ActiveChatState(
      activeSessionId: clearActiveSession
          ? null
          : (activeSessionId ?? this.activeSessionId),
      messages: messages ?? this.messages,
      currentStreamingResponse:
          currentStreamingResponse ?? this.currentStreamingResponse,
      statusMessage: clearStatusMessage
          ? null
          : (statusMessage ?? this.statusMessage),
      streamStatus: streamStatus ?? this.streamStatus,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

final activeChatNotifierProvider =
    StateNotifierProvider<ActiveChatNotifier, ActiveChatState>((ref) {
      final repository = ref.watch(chatRepositoryProvider);
      return ActiveChatNotifier(repository, ref);
    });

class ActiveChatNotifier extends StateNotifier<ActiveChatState> {
  final ChatRepository _repository;
  final Ref _ref;
  StreamSubscription<SseEvent>? _streamSubscription;

  ActiveChatNotifier(this._repository, this._ref)
    : super(const ActiveChatState());

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  /// Loads message history for a given session ID.
  Future<void> loadSession(String sessionId) async {
    _streamSubscription?.cancel();
    state = state.copyWith(
      activeSessionId: sessionId,
      messages: const [],
      currentStreamingResponse: '',
      clearStatusMessage: true,
      streamStatus: StreamStatus.idle,
      clearErrorMessage: true,
    );

    try {
      final history = await _repository.getSessionMessages(sessionId);
      state = state.copyWith(messages: history);
    } catch (e) {
      state = state.copyWith(
        streamStatus: StreamStatus.error,
        errorMessage: 'Failed to load session messages: $e',
      );
    }
  }

  /// Starts a clean new chat session without history.
  void startNewSession() {
    _streamSubscription?.cancel();
    state = const ActiveChatState();
  }

  /// Sends a user prompt and streams the assistant SSE response.
  Future<void> sendMessage(String prompt) async {
    if (prompt.trim().isEmpty) return;

    _streamSubscription?.cancel();

    final userMsg = ChatMessageResponseModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: state.activeSessionId ?? '',
      role: 'user',
      content: prompt.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      currentStreamingResponse: '',
      statusMessage: 'Connecting to assistant...',
      streamStatus: StreamStatus.connecting,
      clearErrorMessage: true,
    );

    final request = ChatRequestModel(
      message: prompt.trim(),
      conversationId: state.activeSessionId,
    );

    final stream = _repository.streamChat(request);

    _streamSubscription = stream.listen(
      (event) {
        switch (event) {
          case SseStatusEvent statusEvt:
            state = state.copyWith(
              statusMessage: statusEvt.message.isNotEmpty
                  ? statusEvt.message
                  : 'Processing prompt...',
            );
            break;
          case SseTokenEvent tokenEvt:
            state = state.copyWith(
              streamStatus: StreamStatus.streaming,
              currentStreamingResponse:
                  state.currentStreamingResponse + tokenEvt.content,
            );
            break;
          case SseDoneEvent doneEvt:
            _finalizeStreamingMessage(doneEvt.conversationId);
            break;
          case SseErrorEvent errorEvt:
            state = state.copyWith(
              streamStatus: StreamStatus.error,
              errorMessage: errorEvt.error,
            );
            break;
        }
      },
      onError: (error) {
        state = state.copyWith(
          streamStatus: StreamStatus.error,
          errorMessage: 'Stream connection error: $error',
        );
      },
      onDone: () {
        if (state.streamStatus == StreamStatus.streaming &&
            state.currentStreamingResponse.isNotEmpty) {
          _finalizeStreamingMessage(null);
        }
      },
    );
  }

  void _finalizeStreamingMessage(String? conversationId) {
    final accumulatedResponse = state.currentStreamingResponse;
    if (accumulatedResponse.isEmpty) {
      state = state.copyWith(
        streamStatus: StreamStatus.idle,
        clearStatusMessage: true,
      );
      return;
    }

    final newSessionId = conversationId ?? state.activeSessionId;

    final assistantMsg = ChatMessageResponseModel(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: newSessionId ?? '',
      role: 'assistant',
      content: accumulatedResponse,
      createdAt: DateTime.now().toIso8601String(),
    );

    state = state.copyWith(
      activeSessionId: newSessionId,
      messages: [...state.messages, assistantMsg],
      currentStreamingResponse: '',
      clearStatusMessage: true,
      streamStatus: StreamStatus.idle,
    );

    // Refresh session list drawer
    _ref.read(chatSessionsProvider.notifier).fetchSessions();
  }
}
