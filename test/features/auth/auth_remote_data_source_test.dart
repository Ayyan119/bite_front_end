import 'package:bite_front_end/core/errors/exception.dart';
import 'package:bite_front_end/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bite_front_end/features/auth/data/models/dev_token_request_model.dart';
import 'package:bite_front_end/features/auth/data/models/login_request_model.dart';
import 'package:bite_front_end/features/auth/data/models/register_request_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class MockDio extends Fake implements Dio {
  Response? mockResponse;
  DioException? mockException;
  String? lastPath;
  dynamic lastData;

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    lastPath = path;
    lastData = data;

    if (mockException != null) {
      throw mockException!;
    }

    return mockResponse as Response<T>;
  }
}

void main() {
  late MockDio mockDio;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    dataSource = AuthRemoteDataSourceImpl(mockDio);
  });

  group('AuthRemoteDataSourceImpl', () {
    test('login returns AuthResponseModel on 200 OK', () async {
      mockDio.mockResponse = Response(
        statusCode: 200,
        data: {
          'access_token': 'fake_token',
          'token_type': 'bearer',
          'expires_in': 86400,
          'user_id': 'user_123',
          'email': 'user@example.com',
        },
        requestOptions: RequestOptions(path: '/auth/login'),
      );

      final result = await dataSource.login(
        const LoginRequestModel(
          email: 'user@example.com',
          password: 'password',
        ),
      );

      expect(result.accessToken, 'fake_token');
      expect(result.userId, 'user_123');
      expect(mockDio.lastPath, '/auth/login');
    });

    test('login throws ServerException on DioException error', () async {
      mockDio.mockException = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          statusCode: 401,
          data: {'detail': 'Invalid credentials'},
          requestOptions: RequestOptions(path: '/auth/login'),
        ),
      );

      expect(
        () => dataSource.login(
          const LoginRequestModel(email: 'user@example.com', password: 'bad'),
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Invalid credentials',
          ),
        ),
      );
    });

    test('register returns AuthResponseModel on 201 Created', () async {
      mockDio.mockResponse = Response(
        statusCode: 201,
        data: {
          'access_token': 'new_token',
          'token_type': 'bearer',
          'expires_in': 86400,
          'user_id': 'user_456',
          'email': 'new@example.com',
        },
        requestOptions: RequestOptions(path: '/auth/register'),
      );

      final result = await dataSource.register(
        const RegisterRequestModel(
          email: 'new@example.com',
          password: 'secret_password',
          displayName: 'New User',
          age: 25,
          heightCm: 175.0,
          weightKg: 70.0,
          gender: 'male',
          activityLevel: 'moderate',
          primaryGoal: 'maintenance',
        ),
      );

      expect(result.accessToken, 'new_token');
      expect(mockDio.lastPath, '/auth/register');
    });

    test('devToken returns AuthResponseModel on 200 OK', () async {
      mockDio.mockResponse = Response(
        statusCode: 200,
        data: {
          'access_token': 'dev_token',
          'token_type': 'bearer',
          'expires_in': 86400,
          'user_id': 'dev_123',
          'email': 'alex@bite.app',
        },
        requestOptions: RequestOptions(path: '/auth/dev-token'),
      );

      final result = await dataSource.devToken(
        const DevTokenRequestModel(email: 'alex@bite.app'),
      );

      expect(result.accessToken, 'dev_token');
      expect(mockDio.lastPath, '/auth/dev-token');
    });
  });
}
