// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:bite_front_end/core/network/sse_client.dart';
import 'package:bite_front_end/features/chat/data/models/chat_session_response_model.dart';
import 'package:bite_front_end/features/chat/data/models/sse_event_model.dart';
import 'package:dio/dio.dart';

Stream<SseEvent> getSseStream({
  required Dio dio,
  required String url,
  required ChatRequestModel request,
  required String? authToken,
}) {
  final controller = StreamController<SseEvent>();
  final httpRequest = html.HttpRequest();

  httpRequest.open('POST', url);
  httpRequest.setRequestHeader('Content-Type', 'application/json');
  httpRequest.setRequestHeader('Accept', 'text/event-stream');
  if (authToken != null && authToken.isNotEmpty) {
    httpRequest.setRequestHeader('Authorization', 'Bearer $authToken');
  }

  int lastProcessedLength = 0;
  final chunkController = StreamController<String>();

  final sseEventSubscription =
      SseClient.parseStringStream(chunkController.stream).listen(
        (event) => controller.add(event),
        onError: (error) =>
            controller.add(SseErrorEvent(error: error.toString())),
        onDone: () => controller.close(),
      );

  void processAccumulatedText() {
    final responseText = httpRequest.responseText ?? '';
    if (responseText.length > lastProcessedLength) {
      final newChunk = responseText.substring(lastProcessedLength);
      lastProcessedLength = responseText.length;
      chunkController.add(newChunk);
    }
  }

  httpRequest.onReadyStateChange.listen((_) {
    processAccumulatedText();
    if (httpRequest.readyState == html.HttpRequest.DONE) {
      if (httpRequest.status != 200) {
        String errorMsg =
            'HTTP ${httpRequest.status}: ${httpRequest.statusText}';
        try {
          final errJson =
              jsonDecode(httpRequest.responseText ?? '')
                  as Map<String, dynamic>;
          if (errJson.containsKey('error') && errJson['error'] is Map) {
            errorMsg = errJson['error']['message'] ?? errorMsg;
          } else if (errJson.containsKey('detail')) {
            errorMsg = errJson['detail'].toString();
          }
        } catch (_) {}
        controller.add(SseErrorEvent(error: errorMsg));
      }
      chunkController.close();
    }
  });

  httpRequest.onError.listen((_) {
    controller.add(
      const SseErrorEvent(
        error: 'Network connection error during Web SSE stream',
      ),
    );
    chunkController.close();
  });

  try {
    httpRequest.send(jsonEncode(request.toJson()));
  } catch (e) {
    controller.add(SseErrorEvent(error: e.toString()));
    chunkController.close();
  }

  controller.onCancel = () {
    sseEventSubscription.cancel();
    httpRequest.abort();
  };

  return controller.stream;
}
