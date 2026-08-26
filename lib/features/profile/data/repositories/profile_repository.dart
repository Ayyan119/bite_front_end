import 'dart:convert';
import 'package:bite_front_end/core/utils/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_profile_response_model.dart';
import '../models/user_profile_update_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return ProfileRepositoryImpl(remoteDataSource, storageService);
});

abstract class ProfileRepository {
  Future<UserProfileResponseModel> getProfile();
  Future<UserProfileResponseModel> updateProfile(
    UserProfileUpdateModel request,
  );
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final StorageService _storageService;

  ProfileRepositoryImpl(this._remoteDataSource, this._storageService);

  @override
  Future<UserProfileResponseModel> getProfile() async {
    try {
      final profile = await _remoteDataSource.getProfile();
      try {
        await _storageService.saveCachedProfile(jsonEncode(profile.toJson()));
      } catch (_) {}
      return profile;
    } catch (e) {
      // 1. Try restoring from local cached JSON
      final cachedJsonStr = _storageService.getCachedProfile();
      if (cachedJsonStr != null && cachedJsonStr.isNotEmpty) {
        try {
          final Map<String, dynamic> jsonMap = jsonDecode(cachedJsonStr);
          return UserProfileResponseModel.fromJson(jsonMap);
        } catch (_) {}
      }

      // 2. Fallback to basic profile constructed from session user data
      final userData = _storageService.getUserData();
      final displayName =
          userData['displayName'] ?? userData['email'] ?? 'User';
      return UserProfileResponseModel(
        id: userData['userId'] ?? '',
        displayName: displayName,
        heightCm: 170,
        weightKg: 70,
        age: 25,
        gender: 'male',
        activityLevel: 'moderate',
        primaryGoal: 'maintenance',
        bmr: 1650,
        tdee: 2200,
        targetCalories: 2000,
        targetProteinG: 120,
        targetCarbsG: 220,
        targetFatG: 65,
        targetMicronutrients: {},
      );
    }
  }

  @override
  Future<UserProfileResponseModel> updateProfile(
    UserProfileUpdateModel request,
  ) async {
    final updatedProfile = await _remoteDataSource.updateProfile(request);
    try {
      await _storageService.saveCachedProfile(
        jsonEncode(updatedProfile.toJson()),
      );
    } catch (_) {}
    return updatedProfile;
  }
}
