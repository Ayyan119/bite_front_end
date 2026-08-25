import 'package:bite_front_end/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:bite_front_end/features/dashboard/data/models/daily_dashboard_response_model.dart';
import 'package:bite_front_end/features/dashboard/data/models/historical_analytics_response_model.dart';
import 'package:bite_front_end/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class MockDashboardRemoteDataSource implements DashboardRemoteDataSource {
  DailyDashboardResponseModel? dailyResponse;
  HistoricalAnalyticsResponseModel? historyResponse;

  @override
  Future<DailyDashboardResponseModel> getDailyDashboard(String dateStr) async {
    return dailyResponse!;
  }

  @override
  Future<HistoricalAnalyticsResponseModel> getHistoricalAnalytics(
    int days,
  ) async {
    return historyResponse!;
  }
}

void main() {
  late MockDashboardRemoteDataSource mockRemoteDataSource;
  late DashboardRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockDashboardRemoteDataSource();
    repository = DashboardRepositoryImpl(mockRemoteDataSource);
  });

  group('DashboardRepositoryImpl', () {
    test('getDailyDashboard delegates to remote data source', () async {
      mockRemoteDataSource.dailyResponse = const DailyDashboardResponseModel(
        date: '2026-08-25',
        targetCalories: 2400.0,
        consumedCalories: 1500.0,
        remainingCalories: 900.0,
        protein: MacroProgressModel(target: 180, consumed: 75, remaining: 105),
        carbs: MacroProgressModel(target: 250, consumed: 200, remaining: 50),
        fat: MacroProgressModel(target: 70, consumed: 35, remaining: 35),
        meals: [],
        topMicronutrients: {},
      );

      final result = await repository.getDailyDashboard('2026-08-25');

      expect(result.date, '2026-08-25');
      expect(result.targetCalories, 2400.0);
    });

    test('getHistoricalAnalytics delegates to remote data source', () async {
      mockRemoteDataSource.historyResponse =
          const HistoricalAnalyticsResponseModel(
            userId: 'user_1',
            totalDaysLogged: 5,
            history: [],
          );

      final result = await repository.getHistoricalAnalytics(7);

      expect(result.userId, 'user_1');
      expect(result.totalDaysLogged, 5);
    });
  });
}
