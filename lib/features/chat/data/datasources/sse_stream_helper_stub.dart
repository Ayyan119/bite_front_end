import 'package:bite_front_end/core/network/sse_client.dart';
import 'package:bite_front_end/features/chat/data/models/chat_session_response_model.dart';
import 'package:bite_front_end/features/chat/data/models/sse_event_model.dart';
import 'package:dio/dio.dart';

Stream<SseEvent> getSseStream({
  required Dio dio,
  required String url,
  required ChatRequestModel request,
  required String? authToken,
}) async* {
  try {
    final response = await dio.post<ResponseBody>(
      url,
      data: request.toJson(),
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          'Accept': 'text/event-stream',
          if (authToken != null && authToken.isNotEmpty)
            'Authorization': 'Bearer $authToken',
        },
      ),
    );

    final stream = response.data?.stream;
    if (stream == null) {
      yield const SseErrorEvent(error: 'No response stream received');
      return;
    }

    yield* SseClient.parseByteStream(stream);
  } on DioException catch (e) {
    yield SseErrorEvent(
      error:
          e.response?.data?['detail']?.toString() ??
          e.message ??
          'Connection error during streaming',
    );
  } catch (e) {
    yield SseErrorEvent(error: e.toString());
  }
}
