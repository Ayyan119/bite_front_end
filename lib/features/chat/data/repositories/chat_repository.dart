import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_message_response_model.dart';
import '../models/chat_session_response_model.dart';
import '../models/sse_event_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final remoteDataSource = ref.watch(chatRemoteDataSourceProvider);
  return ChatRepositoryImpl(remoteDataSource);
});

abstract class ChatRepository {
  Future<List<ChatSessionResponseModel>> getSessions();
  Future<ChatSessionResponseModel> createSession(String title);
  Future<List<ChatMessageResponseModel>> getSessionMessages(String sessionId);
  Future<void> deleteSession(String sessionId);
  Stream<SseEvent> streamChat(ChatRequestModel request);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ChatSessionResponseModel>> getSessions() async {
    return await _remoteDataSource.getSessions();
  }

  @override
  Future<ChatSessionResponseModel> createSession(String title) async {
    return await _remoteDataSource.createSession(
      CreateSessionRequestModel(title: title),
    );
  }

  @override
  Future<List<ChatMessageResponseModel>> getSessionMessages(
    String sessionId,
  ) async {
    return await _remoteDataSource.getSessionMessages(sessionId);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    return await _remoteDataSource.deleteSession(sessionId);
  }

  @override
  Stream<SseEvent> streamChat(ChatRequestModel request) {
    return _remoteDataSource.streamChat(request);
  }
}
