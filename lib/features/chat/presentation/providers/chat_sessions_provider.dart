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
  late final ChatRepository _repository;

  @override
  FutureOr<List<ChatSessionResponseModel>> build() async {
    _repository = ref.watch(chatRepositoryProvider);
    return await _repository.getSessions();
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
}
