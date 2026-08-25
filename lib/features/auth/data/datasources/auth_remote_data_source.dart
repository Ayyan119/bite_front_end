import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../models/auth_response_model.dart';
import '../models/dev_token_request_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSourceImpl(dio);
});

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<AuthResponseModel> devToken(DevTokenRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _dio.post('/auth/login', data: request.toJson());

      if (response.statusCode == 200 && response.data != null) {
        return AuthResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          response.statusMessage ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Login failed';
      throw ServerException(message, statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        return AuthResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          response.statusMessage ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Registration failed';
      throw ServerException(message, statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AuthResponseModel> devToken(DevTokenRequestModel request) async {
    try {
      final response = await _dio.post(
        '/auth/dev-token',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return AuthResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          response.statusMessage ?? 'Dev token generation failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Dev token generation failed';
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
