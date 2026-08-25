import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/daily_dashboard_response_model.dart';
import '../../data/models/historical_analytics_response_model.dart';
import '../../data/repositories/dashboard_repository.dart';

// Currently selected dashboard date (defaults to DateTime.now())
final selectedDashboardDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Currently selected historical range in days (7 or 30 days)
final historicalRangeDaysProvider = StateProvider<int>((ref) => 7);

// Helper extension to format DateTime as YYYY-MM-DD string
String formatDateString(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

// Daily Dashboard summary provider parameterized by date string (YYYY-MM-DD)
final dailyDashboardProvider =
    FutureProvider.family<DailyDashboardResponseModel, String>((
      ref,
      dateStr,
    ) async {
      final repository = ref.watch(dashboardRepositoryProvider);
      return repository.getDailyDashboard(dateStr);
    });

// Historical Analytics provider parameterized by days count (7 or 30)
final historicalAnalyticsProvider =
    FutureProvider.family<HistoricalAnalyticsResponseModel, int>((
      ref,
      days,
    ) async {
      final repository = ref.watch(dashboardRepositoryProvider);
      return repository.getHistoricalAnalytics(days);
    });
