import 'package:bite_front_end/features/chat/data/models/chat_message_response_model.dart';
import 'package:bite_front_end/features/chat/data/models/chat_session_response_model.dart';
import 'package:bite_front_end/features/chat/data/models/sse_event_model.dart';
import 'package:bite_front_end/features/chat/data/repositories/chat_repository.dart';
import 'package:bite_front_end/features/chat/presentation/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockChatRepository implements ChatRepository {
  @override
  Future<List<ChatSessionResponseModel>> getSessions() async => [];

  @override
  Future<ChatSessionResponseModel> createSession(String title) async {
    return ChatSessionResponseModel(
      id: 'sess1',
      userId: 'u1',
      title: title,
      createdAt: '',
      updatedAt: '',
      messageCount: 0,
    );
  }

  @override
  Future<List<ChatMessageResponseModel>> getSessionMessages(
    String sessionId,
  ) async => [];

  @override
  Future<void> deleteSession(String sessionId) async {}

  @override
  Stream<SseEvent> streamChat(ChatRequestModel request) async* {
    yield const SseStatusEvent(status: 'processing', message: 'Analyzing...');
    yield const SseTokenEvent(content: 'Hello!');
    yield const SseDoneEvent(conversationId: 'sess1', status: 'completed');
  }
}

void main() {
  testWidgets('ChatScreen renders title and empty state suggestions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatRepositoryProvider.overrideWithValue(MockChatRepository()),
        ],
        child: const MaterialApp(home: ChatScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('AI Nutrition Assistant'), findsOneWidget);
    expect(
      find.text('How can I help with your nutrition today?'),
      findsOneWidget,
    );
    expect(find.text('Ask nutrition advice or log a meal...'), findsOneWidget);
  });
}
