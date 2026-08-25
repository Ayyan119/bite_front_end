import 'package:bite_front_end/core/utils/storage_service.dart';
import 'package:bite_front_end/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bite_front_end/features/auth/data/models/auth_response_model.dart';
import 'package:bite_front_end/features/auth/data/models/dev_token_request_model.dart';
import 'package:bite_front_end/features/auth/data/models/login_request_model.dart';
import 'package:bite_front_end/features/auth/data/models/register_request_model.dart';
import 'package:bite_front_end/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  AuthResponseModel? responseToReturn;
  Object? errorToThrow;

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    if (errorToThrow != null) throw errorToThrow!;
    return responseToReturn!;
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    if (errorToThrow != null) throw errorToThrow!;
    return responseToReturn!;
  }

  @override
  Future<AuthResponseModel> devToken(DevTokenRequestModel request) async {
    if (errorToThrow != null) throw errorToThrow!;
    return responseToReturn!;
  }
}

class FakeStorageService implements StorageService {
  String? savedToken;
  String? savedUserId;
  String? savedEmail;
  String? savedDisplayName;

  @override
  Future<bool> saveToken(String token) async {
    savedToken = token;
    return true;
  }

  @override
  String? getToken() => savedToken;

  @override
  Future<bool> clearToken() async {
    savedToken = null;
    return true;
  }

  @override
  Future<void> saveUserData({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    savedUserId = userId;
    savedEmail = email;
    savedDisplayName = displayName;
  }

  @override
  Map<String, String?> getUserData() {
    return {
      'userId': savedUserId,
      'email': savedEmail,
      'displayName': savedDisplayName,
    };
  }

  @override
  Future<bool> clearAll() async {
    savedToken = null;
    savedUserId = null;
    savedEmail = null;
    savedDisplayName = null;
    return true;
  }
}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late FakeStorageService fakeStorageService;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    fakeStorageService = FakeStorageService();
    repository = AuthRepositoryImpl(mockRemoteDataSource, fakeStorageService);
  });

  group('AuthRepositoryImpl', () {
    const tAuthResponse = AuthResponseModel(
      accessToken: 'token_abc',
      tokenType: 'bearer',
      expiresIn: 86400,
      userId: 'user_1',
      email: 'test@example.com',
      displayName: 'Test User',
    );

    test('login saves token and user data to storage', () async {
      mockRemoteDataSource.responseToReturn = tAuthResponse;

      final result = await repository.login(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.accessToken, 'token_abc');
      expect(fakeStorageService.savedToken, 'token_abc');
      expect(fakeStorageService.savedUserId, 'user_1');
      expect(fakeStorageService.savedEmail, 'test@example.com');
      expect(fakeStorageService.savedDisplayName, 'Test User');
    });

    test('restoreSession returns null when token is missing', () async {
      final session = await repository.restoreSession();
      expect(session, isNull);
    });

    test(
      'restoreSession returns AuthResponseModel when token and user data exist',
      () async {
        fakeStorageService.savedToken = 'token_abc';
        fakeStorageService.savedUserId = 'user_1';
        fakeStorageService.savedEmail = 'test@example.com';
        fakeStorageService.savedDisplayName = 'Test User';

        final session = await repository.restoreSession();
        expect(session, isNotNull);
        expect(session!.accessToken, 'token_abc');
        expect(session.userId, 'user_1');
        expect(session.email, 'test@example.com');
      },
    );

    test('logout clears storage service', () async {
      fakeStorageService.savedToken = 'token_abc';
      await repository.logout();
      expect(fakeStorageService.savedToken, isNull);
    });
  });
}
