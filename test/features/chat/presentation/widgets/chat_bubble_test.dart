import 'package:bite_front_end/features/chat/data/models/chat_message_response_model.dart';
import 'package:bite_front_end/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseMessageContent', () {
    test(
      'extracts "Looking up nutrition details..." as action step and separates LLM response',
      () {
        const rawText =
            'Looking up nutrition details...One hundred grams of vanilla cake contains approximately 364 calories.';
        final parsed = parseMessageContent(rawText);

        expect(parsed.actionSteps, equals(['Looking up nutrition details...']));
        expect(
          parsed.cleanAnswer,
          equals(
            'One hundred grams of vanilla cake contains approximately 364 calories.',
          ),
        );
      },
    );

    test('extracts multiple action steps correctly', () {
      const rawText =
          'Searching database... Calculating macros... Found 250 kcal!';
      final parsed = parseMessageContent(rawText);

      expect(
        parsed.actionSteps,
        equals(['Searching database...', 'Calculating macros...']),
      );
      expect(parsed.cleanAnswer, equals('Found 250 kcal!'));
    });

    test('handles unicode ellipsis correctly', () {
      const rawText =
          'Looking up nutrition details…One hundred grams of vanilla cake contains approximately 364 calories.';
      final parsed = parseMessageContent(rawText);

      expect(parsed.actionSteps, equals(['Looking up nutrition details…']));
      expect(
        parsed.cleanAnswer,
        equals(
          'One hundred grams of vanilla cake contains approximately 364 calories.',
        ),
      );
    });

    test(
      'returns empty cleanAnswer when rawText contains only action steps',
      () {
        const rawText = 'Looking up nutrition details...';
        final parsed = parseMessageContent(rawText);

        expect(parsed.actionSteps, equals(['Looking up nutrition details...']));
        expect(parsed.cleanAnswer, isEmpty);
      },
    );

    test(
      'returns empty actionSteps for normal LLM responses without action steps',
      () {
        const rawText = 'Here is your daily macro summary.';
        final parsed = parseMessageContent(rawText);

        expect(parsed.actionSteps, isEmpty);
        expect(parsed.cleanAnswer, equals('Here is your daily macro summary.'));
      },
    );
  });

  group('ChatBubble Widget', () {
    testWidgets('renders action step widget and clean LLM response separately', (
      tester,
    ) async {
      final message = ChatMessageResponseModel(
        id: 'msg_1',
        sessionId: 'sess_1',
        role: 'assistant',
        content:
            'Looking up nutrition details...One hundred grams of vanilla cake contains 364 calories.',
        createdAt: DateTime.now().toIso8601String(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ChatBubble(message: message)),
        ),
      );

      await tester.pumpAndSettle();

      // Action step badge should be present
      expect(find.text('1 System Action'), findsOneWidget);

      // Verify RichText contains clean LLM response
      final richTextFinder = find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final text = widget.text.toPlainText();
          return text.contains(
            'One hundred grams of vanilla cake contains 364 calories.',
          );
        }
        return false;
      });

      expect(richTextFinder, findsOneWidget);

      // Verify "Looking up nutrition details..." is NOT in any RichText body
      final invalidRichTextFinder = find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final text = widget.text.toPlainText();
          return text.contains(
            'Looking up nutrition details...One hundred grams',
          );
        }
        return false;
      });

      expect(invalidRichTextFinder, findsNothing);
    });
  });
}
