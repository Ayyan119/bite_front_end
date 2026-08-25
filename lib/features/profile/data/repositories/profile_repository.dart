import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_profile_response_model.dart';
import '../models/user_profile_update_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource);
});

abstract class ProfileRepository {
  Future<UserProfileResponseModel> getProfile();
  Future<UserProfileResponseModel> updateProfile(
    UserProfileUpdateModel request,
  );
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserProfileResponseModel> getProfile() async {
    return await _remoteDataSource.getProfile();
  }

  @override
  Future<UserProfileResponseModel> updateProfile(
    UserProfileUpdateModel request,
  ) async {
    return await _remoteDataSource.updateProfile(request);
  }
}
