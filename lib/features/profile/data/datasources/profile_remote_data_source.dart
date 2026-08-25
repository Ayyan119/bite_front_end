import 'package:bite_front_end/core/constants/api_constants.dart';
import 'package:bite_front_end/core/errors/exception.dart';
import 'package:bite_front_end/core/network/dio_provider.dart';
import 'package:bite_front_end/features/profile/data/models/user_profile_response_model.dart';
import 'package:bite_front_end/features/profile/data/models/user_profile_update_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return ProfileRemoteDataSourceImpl(dio);
});

abstract class ProfileRemoteDataSource {
  Future<UserProfileResponseModel> getProfile();
  Future<UserProfileResponseModel> updateProfile(
    UserProfileUpdateModel request,
  );
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSourceImpl(this._dio);

  @override
  Future<UserProfileResponseModel> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      if (response.statusCode == 200 && response.data != null) {
        return UserProfileResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          response.statusMessage ?? 'Failed to fetch user profile',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Failed to fetch user profile';
      throw ServerException(message, statusCode: e.response?.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserProfileResponseModel> updateProfile(
    UserProfileUpdateModel request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.profile,
        data: request.toJson(),
      );
      if (response.statusCode == 200 && response.data != null) {
        return UserProfileResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          response.statusMessage ?? 'Failed to update user profile',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final message =
          _extractErrorMessage(e) ?? 'Failed to update user profile';
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
