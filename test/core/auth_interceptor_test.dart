import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bite_front_end/core/network/auth_interceptor.dart';
import 'package:bite_front_end/core/utils/storage_service.dart';

class MockRequestInterceptorHandler extends RequestInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
  }
}

class MockErrorInterceptorHandler extends ErrorInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(DioException err) {
    nextCalled = true;
  }
}

void main() {
  late StorageService storageService;
  late AuthInterceptor authInterceptor;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
    authInterceptor = AuthInterceptor(storageService);
  });

  test(
    'onRequest appends Authorization header when token is present',
    () async {
      await storageService.saveToken('sample_bearer_token_xyz');

      final options = RequestOptions(path: '/dashboard/daily');
      final handler = MockRequestInterceptorHandler();

      authInterceptor.onRequest(options, handler);

      expect(
        options.headers['Authorization'],
        equals('Bearer sample_bearer_token_xyz'),
      );
      expect(handler.nextCalled, isTrue);
    },
  );

  test('onRequest omits Authorization header when token is null', () async {
    final options = RequestOptions(path: '/auth/login');
    final handler = MockRequestInterceptorHandler();

    authInterceptor.onRequest(options, handler);

    expect(options.headers.containsKey('Authorization'), isFalse);
    expect(handler.nextCalled, isTrue);
  });

  test('onError clears token on 401 Unauthorized status', () async {
    await storageService.saveToken('sample_bearer_token_xyz');
    expect(storageService.getToken(), equals('sample_bearer_token_xyz'));

    final dioException = DioException(
      requestOptions: RequestOptions(path: '/profile'),
      response: Response(
        requestOptions: RequestOptions(path: '/profile'),
        statusCode: 401,
      ),
    );
    final handler = MockErrorInterceptorHandler();

    await authInterceptor.onError(dioException, handler);

    expect(storageService.getToken(), isNull);
    expect(handler.nextCalled, isTrue);
  });
}
