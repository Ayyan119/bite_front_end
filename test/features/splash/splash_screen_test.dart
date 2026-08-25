import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bite_front_end/app.dart';
import 'package:bite_front_end/core/utils/storage_service.dart';
import 'package:bite_front_end/core/constants/storage_constants.dart';
import 'package:bite_front_end/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:bite_front_end/features/dashboard/data/models/daily_dashboard_response_model.dart';
import 'package:bite_front_end/features/dashboard/data/models/historical_analytics_response_model.dart';

class FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DailyDashboardResponseModel> getDailyDashboard(String dateStr) async {
    return DailyDashboardResponseModel(
      date: dateStr,
      targetCalories: 2400.0,
      consumedCalories: 1800.0,
      remainingCalories: 600.0,
      protein: const MacroProgressModel(
        target: 180,
        consumed: 75,
        remaining: 105,
      ),
      carbs: const MacroProgressModel(
        target: 250,
        consumed: 200,
        remaining: 50,
      ),
      fat: const MacroProgressModel(target: 70, consumed: 35, remaining: 35),
      meals: const [],
      topMicronutrients: const {},
    );
  }

  @override
  Future<HistoricalAnalyticsResponseModel> getHistoricalAnalytics(
    int days,
  ) async {
    return const HistoricalAnalyticsResponseModel(
      userId: 'user_123',
      totalDaysLogged: 1,
      history: [],
    );
  }
}

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
          dashboardRepositoryProvider.overrideWithValue(
            FakeDashboardRepository(),
          ),
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
          dashboardRepositoryProvider.overrideWithValue(
            FakeDashboardRepository(),
          ),
        ],
        child: const BiteApp(),
      ),
    );

    // Advance time beyond splash delay (2 seconds)
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Navigates to HomeScreen when authenticated
    expect(find.text('Macro Trends'), findsOneWidget);
  });
}
