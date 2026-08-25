import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/storage_service.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_model.dart';
import '../models/dev_token_request_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthRepositoryImpl(remoteDataSource, storageService);
});

abstract class AuthRepository {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register(RegisterRequestModel request);

  Future<AuthResponseModel> devToken({required String email, String? userId});

  Future<AuthResponseModel?> restoreSession();

  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final StorageService _storageService;

  AuthRepositoryImpl(this._remoteDataSource, this._storageService);

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequestModel(email: email, password: password);
    final response = await _remoteDataSource.login(request);
    await _persistSession(response);
    return response;
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    final response = await _remoteDataSource.register(request);
    await _persistSession(response);
    return response;
  }

  @override
  Future<AuthResponseModel> devToken({
    required String email,
    String? userId,
  }) async {
    final request = DevTokenRequestModel(email: email, userId: userId);
    final response = await _remoteDataSource.devToken(request);
    await _persistSession(response);
    return response;
  }

  @override
  Future<AuthResponseModel?> restoreSession() async {
    final token = _storageService.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    final userData = _storageService.getUserData();
    final userId = userData['userId'];
    final email = userData['email'];

    if (userId == null || userId.isEmpty || email == null || email.isEmpty) {
      return null;
    }

    return AuthResponseModel(
      accessToken: token,
      tokenType: 'bearer',
      expiresIn: 86400,
      userId: userId,
      email: email,
      displayName: userData['displayName'],
    );
  }

  @override
  Future<void> logout() async {
    await _storageService.clearAll();
  }

  Future<void> _persistSession(AuthResponseModel authResponse) async {
    await _storageService.saveToken(authResponse.accessToken);
    await _storageService.saveUserData(
      userId: authResponse.userId,
      email: authResponse.email,
      displayName: authResponse.displayName,
    );
  }
}
