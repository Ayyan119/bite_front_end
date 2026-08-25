import 'package:bite_front_end/features/auth/data/models/auth_response_model.dart';
import 'package:bite_front_end/features/auth/data/models/register_request_model.dart';
import 'package:bite_front_end/features/auth/data/repositories/auth_repository.dart';
import 'package:bite_front_end/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthRepository implements AuthRepository {
  AuthResponseModel? sessionToRestore;
  AuthResponseModel? loginToReturn;
  Object? errorToThrow;

  @override
  Future<AuthResponseModel?> restoreSession() async {
    if (errorToThrow != null) throw errorToThrow!;
    return sessionToRestore;
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return loginToReturn!;
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    if (errorToThrow != null) throw errorToThrow!;
    return loginToReturn!;
  }

  @override
  Future<AuthResponseModel> devToken({
    required String email,
    String? userId,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return loginToReturn!;
  }

  @override
  Future<void> logout() async {
    sessionToRestore = null;
  }
}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );
  }

  group('AuthNotifier', () {
    const tAuthResponse = AuthResponseModel(
      accessToken: 'token_xyz',
      tokenType: 'bearer',
      expiresIn: 86400,
      userId: 'user_10',
      email: 'alex@bite.app',
    );

    test('initial build restores session', () async {
      mockAuthRepository.sessionToRestore = tAuthResponse;
      final container = makeContainer();

      final state = await container.read(authNotifierProvider.future);
      expect(state?.accessToken, 'token_xyz');
      expect(state?.email, 'alex@bite.app');
    });

    test('login updates state to AsyncValue.data', () async {
      mockAuthRepository.loginToReturn = tAuthResponse;
      final container = makeContainer();

      final notifier = container.read(authNotifierProvider.notifier);
      await notifier.login(email: 'alex@bite.app', password: 'password');

      final state = container.read(authNotifierProvider);
      expect(state.value?.accessToken, 'token_xyz');
    });

    test('logout resets state to null data', () async {
      mockAuthRepository.sessionToRestore = tAuthResponse;
      final container = makeContainer();
      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.logout();
      final state = container.read(authNotifierProvider);
      expect(state.value, isNull);
    });
  });
}
