import 'package:bite_front_end/features/dashboard/presentation/widgets/macro_cards_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MacroCardsGrid renders Protein, Carbs, Fat values', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MacroCardsGrid(
            currentProteinG: 120,
            targetProteinG: 180,
            currentCarbsG: 150,
            targetCarbsG: 250,
            currentFatG: 45,
            targetFatG: 70,
          ),
        ),
      ),
    );

    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('Carbs'), findsOneWidget);
    expect(find.text('Fat'), findsOneWidget);
    expect(find.textContaining('120g', findRichText: true), findsOneWidget);
    expect(find.textContaining('150g', findRichText: true), findsOneWidget);
    expect(find.textContaining('45g', findRichText: true), findsOneWidget);
  });
}
