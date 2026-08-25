import 'package:bite_front_end/core/errors/exception.dart';
import 'package:bite_front_end/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class MockDio extends Fake implements Dio {
  Response? mockResponse;
  DioException? mockException;
  String? lastPath;
  Map<String, dynamic>? lastQueryParameters;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    lastPath = path;
    lastQueryParameters = queryParameters;

    if (mockException != null) {
      throw mockException!;
    }

    return mockResponse as Response<T>;
  }
}

void main() {
  late MockDio mockDio;
  late DashboardRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    dataSource = DashboardRemoteDataSourceImpl(mockDio);
  });

  group('DashboardRemoteDataSourceImpl', () {
    test(
      'getDailyDashboard returns DailyDashboardResponseModel on 200 OK',
      () async {
        mockDio.mockResponse = Response(
          statusCode: 200,
          data: {
            'date': '2026-08-25',
            'target_calories': 2400.0,
            'consumed_calories': 1800.0,
            'remaining_calories': 600.0,
            'protein': {'target': 180.0, 'consumed': 75.0, 'remaining': 105.0},
            'carbs': {'target': 250.0, 'consumed': 200.0, 'remaining': 50.0},
            'fat': {'target': 70.0, 'consumed': 35.0, 'remaining': 35.0},
            'meals': [],
            'top_micronutrients': {'Fiber': 30.0},
          },
          requestOptions: RequestOptions(path: '/dashboard/daily'),
        );

        final result = await dataSource.getDailyDashboard('2026-08-25');

        expect(result.date, '2026-08-25');
        expect(result.consumedCalories, 1800.0);
        expect(mockDio.lastPath, '/dashboard/daily');
        expect(mockDio.lastQueryParameters?['target_date'], '2026-08-25');
      },
    );

    test(
      'getDailyDashboard throws ServerException on DioException error',
      () async {
        mockDio.mockException = DioException(
          requestOptions: RequestOptions(path: '/dashboard/daily'),
          response: Response(
            statusCode: 500,
            data: {'detail': 'Server error'},
            requestOptions: RequestOptions(path: '/dashboard/daily'),
          ),
        );

        expect(
          () => dataSource.getDailyDashboard('2026-08-25'),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Server error',
            ),
          ),
        );
      },
    );

    test(
      'getHistoricalAnalytics returns HistoricalAnalyticsResponseModel on 200 OK',
      () async {
        mockDio.mockResponse = Response(
          statusCode: 200,
          data: {'user_id': 'user_123', 'total_days_logged': 1, 'history': []},
          requestOptions: RequestOptions(path: '/dashboard/history'),
        );

        final result = await dataSource.getHistoricalAnalytics(30);

        expect(result.userId, 'user_123');
        expect(mockDio.lastPath, '/dashboard/history');
        expect(mockDio.lastQueryParameters?['days'], 30);
      },
    );
  });
}
