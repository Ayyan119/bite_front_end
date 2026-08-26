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
        if (detail is String && detail.isNotEmpty) {
          final lower = detail.toLowerCase();
          if (lower.contains('already') ||
              lower.contains('exist') ||
              lower.contains('registered') ||
              lower.contains('duplicate')) {
            return 'Email address is already registered. Please log in instead.';
          }
          return detail;
        }
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map) {
            final msg = first['msg']?.toString() ?? first.toString();
            final field =
                (first['loc'] is List && (first['loc'] as List).isNotEmpty)
                ? "${(first['loc'] as List).last}: "
                : "";
            return "$field$msg";
          }
          return detail.first.toString();
        }
      }
      if (data.containsKey('message') && data['message'] != null) {
        return data['message'].toString();
      }
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return 'Incorrect email or password. Please try again.';
    }
    if (statusCode == 409) {
      return 'An account with this email address already exists.';
    }
    if (statusCode == 422) {
      return 'Invalid input details. Please check your information and try again.';
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Unable to connect to server. Please check your connection.';
    }

    return e.message ?? 'Authentication error. Please check your details.';
  }
}
