import 'dart:async';
import 'dart:convert';
import 'package:bite_front_end/features/chat/data/models/sse_event_model.dart';

/// Parses raw Server-Sent Events (SSE) byte/string streams into a stream of [SseEvent]s.
class SseClient {
  /// Converts an incoming byte stream into `Stream<SseEvent>`.
  static Stream<SseEvent> parseByteStream(Stream<dynamic> byteStream) {
    final stringStream = byteStream.map<String>((chunk) {
      if (chunk is String) return chunk;
      if (chunk is List<int>) return utf8.decode(chunk, allowMalformed: true);
      return chunk.toString();
    });
    return parseStringStream(stringStream);
  }

  /// Converts a text stream of SSE frames into a stream of typed [SseEvent]s.
  static Stream<SseEvent> parseStringStream(Stream<String> stringStream) {
    final controller = StreamController<SseEvent>();
    String buffer = '';
    String? currentEvent;
    String currentData = '';

    void processLine(String line) {
      final trimmed = line.trimRight();
      if (trimmed.isEmpty) {
        // Event block completed
        if (currentData.isNotEmpty) {
          try {
            final jsonMap = jsonDecode(currentData) as Map<String, dynamic>;
            final eventType =
                currentEvent ?? (jsonMap['event_type'] as String?) ?? 'message';

            if (eventType == 'done' || jsonMap['status'] == 'completed') {
              controller.add(
                SseDoneEvent(
                  conversationId: jsonMap['conversation_id'] as String? ?? '',
                  status: jsonMap['status'] as String? ?? 'completed',
                ),
              );
            } else if (eventType == 'status' &&
                jsonMap.containsKey('message') &&
                !jsonMap.containsKey('content')) {
              controller.add(
                SseStatusEvent(
                  status: jsonMap['status'] as String? ?? 'processing',
                  message: jsonMap['message'] as String? ?? '',
                ),
              );
            } else if (jsonMap.containsKey('content') ||
                eventType == 'token' ||
                eventType == 'message') {
              controller.add(
                SseTokenEvent(content: jsonMap['content'] as String? ?? ''),
              );
            }
          } catch (e) {
            controller.add(
              SseErrorEvent(error: 'Failed to parse SSE json: $e'),
            );
          }
        }
        currentEvent = null;
        currentData = '';
        return;
      }

      if (trimmed.startsWith('event:')) {
        currentEvent = trimmed.substring(6).trim();
      } else if (trimmed.startsWith('data:')) {
        final dataContent = trimmed.substring(5).trim();
        if (currentData.isEmpty) {
          currentData = dataContent;
        } else {
          currentData += '\n$dataContent';
        }
      }
    }

    final subscription = stringStream.listen(
      (chunk) {
        buffer += chunk;
        while (buffer.contains('\n')) {
          final index = buffer.indexOf('\n');
          final line = buffer.substring(0, index);
          buffer = buffer.substring(index + 1);
          processLine(line);
        }
      },
      onError: (error) {
        controller.add(SseErrorEvent(error: error.toString()));
        controller.close();
      },
      onDone: () {
        if (buffer.isNotEmpty) {
          processLine(buffer);
        }
        // Dispatch any final buffered block
        processLine('');
        controller.close();
      },
      cancelOnError: false,
    );

    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }
}
