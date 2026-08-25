import 'package:bite_front_end/core/constants/api_constants.dart';
import 'package:bite_front_end/core/errors/exception.dart';
import 'package:bite_front_end/core/network/dio_provider.dart';
import 'package:bite_front_end/core/utils/storage_service.dart';
import 'package:bite_front_end/features/chat/data/models/chat_message_response_model.dart';
import 'package:bite_front_end/features/chat/data/models/chat_session_response_model.dart';
import 'package:bite_front_end/features/chat/data/models/sse_event_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sse_stream_helper.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final storageService = ref.watch(storageServiceProvider);
  return ChatRemoteDataSourceImpl(dio, storageService);
});

abstract class ChatRemoteDataSource {
  Future<List<ChatSessionResponseModel>> getSessions();
  Future<ChatSessionResponseModel> createSession(
    CreateSessionRequestModel request,
  );
  Future<List<ChatMessageResponseModel>> getSessionMessages(String sessionId);
  Future<void> deleteSession(String sessionId);
  Stream<SseEvent> streamChat(ChatRequestModel request);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio _dio;
  final StorageService _storageService;

  ChatRemoteDataSourceImpl(this._dio, this._storageService);

  @override
  Future<List<ChatSessionResponseModel>> getSessions() async {
    try {
      final response = await _dio.get(ApiConstants.chatSessions);
      if (response.data is List) {
        return (response.data as List)
            .map(
              (e) =>
                  ChatSessionResponseModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e) ?? 'Failed to load chat sessions',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ChatSessionResponseModel> createSession(
    CreateSessionRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.chatSessions,
        data: request.toJson(),
      );
      return ChatSessionResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e) ?? 'Failed to create chat session',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ChatMessageResponseModel>> getSessionMessages(
    String sessionId,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.chatSessionMessages(sessionId),
      );
      if (response.data is List) {
        return (response.data as List)
            .map(
              (e) =>
                  ChatMessageResponseModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e) ?? 'Failed to load session messages',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      await _dio.delete(ApiConstants.chatSessionDelete(sessionId));
    } on DioException catch (e) {
      throw ServerException(
        _extractErrorMessage(e) ?? 'Failed to delete chat session',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<SseEvent> streamChat(ChatRequestModel request) {
    final token = _storageService.getToken();
    final fullUrl = '${ApiConstants.baseUrl}${ApiConstants.chat}';
    return getSseStream(
      dio: _dio,
      url: fullUrl,
      request: request,
      authToken: token,
    );
  }

  String? _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          return detail.first.toString();
        }
      }
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
    }
    return e.message;
  }
}
