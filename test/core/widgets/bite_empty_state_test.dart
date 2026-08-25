import 'package:bite_front_end/core/widgets/bite_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BiteEmptyState renders title, message, and action button', (
    tester,
  ) async {
    bool actionTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BiteEmptyState(
            title: 'No Meals Found',
            message: 'You have not logged any meals today.',
            actionLabel: 'Log Meal',
            onActionPressed: () => actionTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('No Meals Found'), findsOneWidget);
    expect(find.text('You have not logged any meals today.'), findsOneWidget);
    expect(find.text('Log Meal'), findsOneWidget);

    await tester.tap(find.text('Log Meal'));
    expect(actionTapped, isTrue);
  });
}
