import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bite_front_end/app.dart';
import 'package:bite_front_end/core/utils/storage_service.dart';
import 'package:bite_front_end/core/constants/storage_constants.dart';

void main() {
  testWidgets(
    'App renders bite splash and navigates to home when authenticated',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        StorageConstants.accessToken: 'test_token',
        StorageConstants.userId: 'user_123',
        StorageConstants.userEmail: 'user@example.com',
      });
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
    },
  );
}
