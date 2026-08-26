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
    try {
      final updatedProfile = await _remoteDataSource.updateProfile(request);
      try {
        await _storageService.saveCachedProfile(
          jsonEncode(updatedProfile.toJson()),
        );
      } catch (_) {}
      return updatedProfile;
    } catch (_) {
      final currentProfile = await getProfile();
      final height = request.heightCm ?? currentProfile.heightCm;
      final weight = request.weightKg ?? currentProfile.weightKg;
      final age = request.age ?? currentProfile.age;
      final gender = request.gender ?? currentProfile.gender;
      final activity = request.activityLevel ?? currentProfile.activityLevel;
      final goal = request.primaryGoal ?? currentProfile.primaryGoal;

      // Recalculate BMR (Mifflin-St Jeor) & TDEE
      final isMale = gender.toLowerCase() == 'male';
      final bmr = isMale
          ? (10 * weight + 6.25 * height - 5 * age + 5)
          : (10 * weight + 6.25 * height - 5 * age - 161);

      double mult = 1.55;
      if (activity.contains('sedentary')) {
        mult = 1.2;
      } else if (activity.contains('light')) {
        mult = 1.375;
      } else if (activity.contains('very')) {
        mult = 1.9;
      } else if (activity.contains('active')) {
        mult = 1.725;
      }

      final tdee = bmr * mult;
      double targetCal = tdee;
      if (goal.contains('weight') || goal.contains('loss')) {
        targetCal = tdee - 500;
      } else if (goal.contains('muscle') || goal.contains('gain')) {
        targetCal = tdee + 300;
      }

      final proteinG = (2.0 * weight).roundToDouble();
      final fatG = (0.9 * weight).roundToDouble();
      final carbsG = ((targetCal - (proteinG * 4 + fatG * 9)) / 4)
          .clamp(0.0, 1000.0)
          .roundToDouble();

      final fallbackUpdated = UserProfileResponseModel(
        id: currentProfile.id,
        displayName: request.displayName ?? currentProfile.displayName,
        heightCm: height,
        weightKg: weight,
        age: age,
        gender: gender,
        activityLevel: activity,
        primaryGoal: goal,
        bmr: bmr,
        tdee: tdee,
        targetCalories: targetCal,
        targetProteinG: proteinG,
        targetCarbsG: carbsG,
        targetFatG: fatG,
        targetMicronutrients: currentProfile.targetMicronutrients,
      );

      try {
        await _storageService.saveCachedProfile(
          jsonEncode(fallbackUpdated.toJson()),
        );
      } catch (_) {}

      return fallbackUpdated;
    }
  }
}
