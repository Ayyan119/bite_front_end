import 'package:bite_front_end/core/widgets/bite_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BiteErrorState renders title, message, and triggers retry', (
    tester,
  ) async {
    bool retryTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BiteErrorState(
            title: 'Server Error',
            message: 'Failed to connect to backend server.',
            onRetry: () => retryTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Server Error'), findsOneWidget);
    expect(find.text('Failed to connect to backend server.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    expect(retryTapped, isTrue);
  });
}
