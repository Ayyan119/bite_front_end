import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../models/daily_dashboard_response_model.dart';
import '../models/historical_analytics_response_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final remoteDataSource = ref.watch(dashboardRemoteDataSourceProvider);
  return DashboardRepositoryImpl(remoteDataSource);
});

abstract class DashboardRepository {
  Future<DailyDashboardResponseModel> getDailyDashboard(String dateStr);
  Future<HistoricalAnalyticsResponseModel> getHistoricalAnalytics(int days);
}

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<DailyDashboardResponseModel> getDailyDashboard(String dateStr) async {
    return await _remoteDataSource.getDailyDashboard(dateStr);
  }

  @override
  Future<HistoricalAnalyticsResponseModel> getHistoricalAnalytics(
    int days,
  ) async {
    return await _remoteDataSource.getHistoricalAnalytics(days);
  }
}
