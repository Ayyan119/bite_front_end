import 'dart:convert';
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
    dynamic responseData = e.response?.data;
    if (responseData is String) {
      try {
        responseData = jsonDecode(responseData);
      } catch (_) {}
    }

    if (responseData != null && responseData is Map) {
      final data = responseData;
      if (data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String && detail.isNotEmpty) {
          final lower = detail.toLowerCase();
          if (lower.contains('already') ||
              lower.contains('exist') ||
              lower.contains('registered') ||
              lower.contains('duplicate') ||
              lower.contains('in use') ||
              lower.contains('taken')) {
            return 'An account with this email address already exists. Please log in or use a different email.';
          }
          return detail;
        }
        if (detail is List && detail.isNotEmpty) {
          final messages = <String>[];
          for (final item in detail) {
            if (item is Map) {
              final msg = item['msg']?.toString() ?? item.toString();
              String fieldName = '';
              if (item['loc'] is List && (item['loc'] as List).isNotEmpty) {
                final locLast = (item['loc'] as List).last.toString();
                if (locLast != 'body') {
                  fieldName = locLast
                      .replaceAll('_', ' ')
                      .split(' ')
                      .map(
                        (w) => w.isNotEmpty
                            ? '${w[0].toUpperCase()}${w.substring(1)}'
                            : '',
                      )
                      .join(' ');
                }
              }
              messages.add(fieldName.isNotEmpty ? '$fieldName: $msg' : msg);
            } else if (item != null) {
              messages.add(item.toString());
            }
          }
          if (messages.isNotEmpty) {
            return messages.join('\n');
          }
        }
      }
      if (data.containsKey('message') && data['message'] != null) {
        final msgStr = data['message'].toString();
        final lower = msgStr.toLowerCase();
        if (lower.contains('already') ||
            lower.contains('exist') ||
            lower.contains('registered') ||
            lower.contains('duplicate') ||
            lower.contains('in use') ||
            lower.contains('taken')) {
          return 'An account with this email address already exists. Please log in or use a different email.';
        }
        return msgStr;
      }
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return 'Incorrect email or password. Please try again.';
    }
    if (statusCode == 409) {
      return 'An account with this email address already exists. Please log in or use a different email.';
    }
    if (statusCode == 422) {
      return 'Please check your information and ensure all required fields are filled correctly.';
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Unable to connect to server. Please check your connection.';
    }

    return e.message ?? 'Authentication error. Please check your details.';
  }
}
