import 'package:bite_front_end/features/dashboard/data/models/daily_dashboard_response_model.dart';
import 'package:bite_front_end/features/dashboard/data/models/historical_analytics_response_model.dart';
import 'package:bite_front_end/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:bite_front_end/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockDashboardRepository implements DashboardRepository {
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
      userId: 'user_1',
      totalDaysLogged: 3,
      history: [],
    );
  }
}

void main() {
  test('formatDateString formats DateTime as YYYY-MM-DD', () {
    final date = DateTime(2026, 8, 25);
    expect(formatDateString(date), '2026-08-25');
  });

  test('selectedDashboardDateProvider initial state is current date', () {
    final container = ProviderContainer();
    final date = container.read(selectedDashboardDateProvider);
    expect(date.year, DateTime.now().year);
  });

  test('dailyDashboardProvider fetches daily summary for given date', () async {
    final container = ProviderContainer(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(
          MockDashboardRepository(),
        ),
      ],
    );

    final dashboard = await container.read(
      dailyDashboardProvider('2026-08-25').future,
    );
    expect(dashboard.date, '2026-08-25');
    expect(dashboard.targetCalories, 2400.0);
  });
}
