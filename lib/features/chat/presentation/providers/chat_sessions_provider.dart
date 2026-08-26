import 'dart:async';
import 'package:bite_front_end/features/chat/data/models/chat_session_response_model.dart';
import 'package:bite_front_end/features/chat/data/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatSessionsProvider =
    AsyncNotifierProvider<ChatSessionsNotifier, List<ChatSessionResponseModel>>(
      ChatSessionsNotifier.new,
    );

class ChatSessionsNotifier
    extends AsyncNotifier<List<ChatSessionResponseModel>> {
  ChatRepository get _repository => ref.read(chatRepositoryProvider);

  @override
  FutureOr<List<ChatSessionResponseModel>> build() async {
    return await ref.watch(chatRepositoryProvider).getSessions();
  }

  Future<void> fetchSessions() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getSessions());
  }

  Future<ChatSessionResponseModel?> createSession(String title) async {
    try {
      final newSession = await _repository.createSession(title);
      final currentList = state.value ?? [];
      state = AsyncValue.data([newSession, ...currentList]);
      return newSession;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _repository.deleteSession(sessionId);
      final currentList = state.value ?? [];
      state = AsyncValue.data(
        currentList.where((s) => s.id != sessionId).toList(),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> clearAllSessions() async {
    final currentList = state.value ?? [];
    if (currentList.isEmpty) return;

    try {
      // Delete all sessions on backend
      await Future.wait(
        currentList.map((s) => _repository.deleteSession(s.id)),
      );
      state = const AsyncValue.data([]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
