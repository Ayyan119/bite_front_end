import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../models/daily_dashboard_response_model.dart';
import '../models/historical_analytics_response_model.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return DashboardRemoteDataSourceImpl(dio);
});

abstract class DashboardRemoteDataSource {
  Future<DailyDashboardResponseModel> getDailyDashboard(String dateStr);
  Future<HistoricalAnalyticsResponseModel> getHistoricalAnalytics(int days);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio _dio;

  DashboardRemoteDataSourceImpl(this._dio);

  @override
  Future<DailyDashboardResponseModel> getDailyDashboard(String dateStr) async {
    try {
      final response = await _dio.get(
        '/dashboard/daily',
        queryParameters: {'target_date': dateStr},
      );

      if (response.statusCode == 200 && response.data != null) {
        return DailyDashboardResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          response.statusMessage ?? 'Failed to fetch daily dashboard',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final message =
          _extractErrorMessage(e) ?? 'Failed to fetch daily dashboard';
      throw ServerException(message, statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<HistoricalAnalyticsResponseModel> getHistoricalAnalytics(
    int days,
  ) async {
    try {
      final response = await _dio.get(
        '/dashboard/history',
        queryParameters: {'days': days},
      );

      if (response.statusCode == 200 && response.data != null) {
        return HistoricalAnalyticsResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          response.statusMessage ?? 'Failed to fetch historical analytics',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final message =
          _extractErrorMessage(e) ?? 'Failed to fetch historical analytics';
      throw ServerException(message, statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  String? _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          return detail.first.toString();
        }
      }
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
    }
    return e.message;
  }
}
