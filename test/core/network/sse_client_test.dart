import 'dart:async';
import 'package:bite_front_end/core/network/sse_client.dart';
import 'package:bite_front_end/features/chat/data/models/sse_event_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SseClient Parser Tests', () {
    test('parses status, message, and done events correctly', () async {
      final sseStreamInput = Stream.fromIterable([
        'event: status\ndata: {"status": "processing_prompt", "message": "Analyzing prompt..."}\n\n',
        'event: message\ndata: {"content": "Hello "}\n\n',
        'event: message\ndata: {"content": "world!"}\n\n',
        'event: done\ndata: {"conversation_id": "session-123", "status": "completed"}\n\n',
      ]);

      final events = await SseClient.parseStringStream(sseStreamInput).toList();

      expect(events.length, 4);

      expect(events[0], isA<SseStatusEvent>());
      final statusEvent = events[0] as SseStatusEvent;
      expect(statusEvent.status, 'processing_prompt');
      expect(statusEvent.message, 'Analyzing prompt...');

      expect(events[1], isA<SseTokenEvent>());
      expect((events[1] as SseTokenEvent).content, 'Hello ');

      expect(events[2], isA<SseTokenEvent>());
      expect((events[2] as SseTokenEvent).content, 'world!');

      expect(events[3], isA<SseDoneEvent>());
      final doneEvent = events[3] as SseDoneEvent;
      expect(doneEvent.conversationId, 'session-123');
      expect(doneEvent.status, 'completed');
    });

    test('handles chunked split lines across stream emissions', () async {
      final controller = StreamController<String>();

      final parsedStream = SseClient.parseStringStream(controller.stream);
      final eventsFuture = parsedStream.toList();

      controller.add('event: stat');
      controller.add('us\ndata: {"status": "ok", "message": "Ready"}\n\n');
      controller.close();

      final events = await eventsFuture;
      expect(events.length, 1);
      expect(events[0], isA<SseStatusEvent>());
      expect((events[0] as SseStatusEvent).message, 'Ready');
    });
  });
}
