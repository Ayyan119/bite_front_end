import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bite_front_end/app.dart';
import 'package:bite_front_end/core/utils/storage_service.dart';

void main() {
  testWidgets('App renders bite splash and navigates to home', (
    WidgetTester tester,
  ) async {
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

    // Initial splash rendering
    expect(find.text('AI-Powered Nutrition & Health'), findsOneWidget);

    // Advance splash screen timer (2s)
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Navigates to HomeScreen
    expect(find.text('Daily Macro Goals'), findsOneWidget);
  });
}
