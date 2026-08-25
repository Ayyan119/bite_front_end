import 'dart:async';
import 'package:bite_front_end/features/chat/data/models/chat_message_response_model.dart';
import 'package:bite_front_end/features/chat/data/models/chat_session_response_model.dart';
import 'package:bite_front_end/features/chat/data/models/sse_event_model.dart';
import 'package:bite_front_end/features/chat/data/repositories/chat_repository.dart';
import 'package:bite_front_end/features/chat/presentation/providers/active_chat_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeChatRepository implements ChatRepository {
  List<ChatMessageResponseModel> mockMessages = [];
  List<ChatSessionResponseModel> mockSessions = [];
  final StreamController<SseEvent> streamController =
      StreamController<SseEvent>.broadcast();

  @override
  Future<List<ChatSessionResponseModel>> getSessions() async => mockSessions;

  @override
  Future<ChatSessionResponseModel> createSession(String title) async {
    final session = ChatSessionResponseModel(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user123',
      title: title,
      createdAt: '2026-08-25',
      updatedAt: '2026-08-25',
      messageCount: 0,
    );
    mockSessions.add(session);
    return session;
  }

  @override
  Future<List<ChatMessageResponseModel>> getSessionMessages(
    String sessionId,
  ) async => mockMessages;

  @override
  Future<void> deleteSession(String sessionId) async {
    mockSessions.removeWhere((s) => s.id == sessionId);
  }

  @override
  Stream<SseEvent> streamChat(ChatRequestModel request) =>
      streamController.stream;
}

void main() {
  late ProviderContainer container;
  late FakeChatRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeChatRepository();
    container = ProviderContainer(
      overrides: [chatRepositoryProvider.overrideWithValue(fakeRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is idle with empty message list', () {
    final state = container.read(activeChatNotifierProvider);
    expect(state.streamStatus, StreamStatus.idle);
    expect(state.messages, isEmpty);
    expect(state.activeSessionId, isNull);
  });

  test('loadSession populates message history', () async {
    fakeRepository.mockMessages = [
      const ChatMessageResponseModel(
        id: 'msg1',
        sessionId: 'session1',
        role: 'user',
        content: 'Hi',
        createdAt: '2026-08-25',
      ),
    ];

    final notifier = container.read(activeChatNotifierProvider.notifier);
    await notifier.loadSession('session1');

    final state = container.read(activeChatNotifierProvider);
    expect(state.activeSessionId, 'session1');
    expect(state.messages.length, 1);
    expect(state.messages.first.content, 'Hi');
  });

  test('sendMessage updates status and streams response tokens', () async {
    final notifier = container.read(activeChatNotifierProvider.notifier);

    unawaited(notifier.sendMessage('Log lunch'));

    var state = container.read(activeChatNotifierProvider);
    expect(state.messages.length, 1);
    expect(state.messages.first.role, 'user');
    expect(state.streamStatus, StreamStatus.connecting);

    // Emit status event
    fakeRepository.streamController.add(
      const SseStatusEvent(
        status: 'processing',
        message: 'Analyzing prompt...',
      ),
    );

    await Future.delayed(Duration.zero);
    state = container.read(activeChatNotifierProvider);
    expect(state.statusMessage, 'Analyzing prompt...');

    // Emit token event
    fakeRepository.streamController.add(
      const SseTokenEvent(content: 'Logged '),
    );
    fakeRepository.streamController.add(const SseTokenEvent(content: 'Lunch'));

    await Future.delayed(Duration.zero);
    state = container.read(activeChatNotifierProvider);
    expect(state.streamStatus, StreamStatus.streaming);
    expect(state.currentStreamingResponse, 'Logged Lunch');

    // Emit done event
    fakeRepository.streamController.add(
      const SseDoneEvent(conversationId: 'sess_100', status: 'completed'),
    );

    await Future.delayed(Duration.zero);
    state = container.read(activeChatNotifierProvider);
    expect(state.streamStatus, StreamStatus.idle);
    expect(state.messages.length, 2);
    expect(state.messages.last.role, 'assistant');
    expect(state.messages.last.content, 'Logged Lunch');
    expect(state.activeSessionId, 'sess_100');
  });
}
