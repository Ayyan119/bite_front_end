import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bite_front_end/app.dart';
import 'package:bite_front_end/core/utils/storage_service.dart';
import 'package:bite_front_end/core/constants/storage_constants.dart';

void main() {
  testWidgets('SplashScreen redirects unauthenticated user to LoginScreen', (
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

    // Initial splash render
    expect(find.text('AI-Powered Nutrition & Health'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);

    // Advance time beyond splash delay (2 seconds)
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Navigates to LoginScreen when unauthenticated
    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('SplashScreen redirects authenticated user to HomeScreen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      StorageConstants.accessToken: 'valid_jwt_token',
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

    // Advance time beyond splash delay (2 seconds)
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Navigates to HomeScreen when authenticated
    expect(find.text('Daily Macro Goals'), findsOneWidget);
  });
}
