import 'package:bite_front_end/features/dashboard/presentation/widgets/date_selector_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DateSelectorBar renders today label and chevron buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: DateSelectorBar())),
      ),
    );

    expect(find.textContaining('Today'), findsOneWidget);
    expect(find.byTooltip('Previous Day'), findsOneWidget);
    expect(find.byTooltip('Next Day'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous Day'));
    await tester.pumpAndSettle();
  });
}
