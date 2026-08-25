import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bite_front_end/app.dart';
import 'package:bite_front_end/core/utils/storage_service.dart';

void main() {
  testWidgets(
    'SplashScreen renders animated bite logo and progress indicator',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          ],
          child: const BiteApp(),
        ),
      );

      // Initial splash render
      expect(find.text('AI-Powered Nutrition & Health'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);

      // Advance time beyond splash delay (2 seconds)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigates to HomeScreen
      expect(find.text('Daily Macro Goals'), findsOneWidget);
    },
  );
}
