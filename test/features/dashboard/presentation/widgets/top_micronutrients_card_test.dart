import 'package:bite_front_end/features/dashboard/presentation/widgets/top_micronutrients_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TopMicronutrientsCard', () {
    testWidgets(
      'categorizes Fatty Acids and Hydration correctly and renders nutrient stat chips',
      (tester) async {
        final Map<String, double> sampleMicros = {
          'Saturated Fat (g)': 12.5,
          'Monounsaturated Fat (g)': 8.4,
          'Water (g)': 850.0,
          'Calcium, Ca (mg)': 300.0,
          'Vitamin C (mg)': 60.0,
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TopMicronutrientsCard(topMicronutrients: sampleMicros),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Ensure key header is visible
        expect(find.text('Key Micronutrients'), findsOneWidget);

        // Tap 'Fatty Acids' category tab
        await tester.tap(find.text('Fatty Acids'));
        await tester.pumpAndSettle();

        // Saturated Fat and Monounsaturated Fat should be visible under Fatty Acids
        expect(find.textContaining('Saturated Fat'), findsOneWidget);
        expect(find.textContaining('12.5'), findsOneWidget);

        // Tap 'Hydration' category tab
        await tester.tap(find.text('Hydration'));
        await tester.pumpAndSettle();

        // Water (g) should be visible under Hydration
        expect(find.textContaining('Water (g)'), findsOneWidget);
        expect(find.textContaining('850.0'), findsOneWidget);
      },
    );
  });
}
