import 'dart:async';
import 'package:bite_front_end/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:bite_front_end/features/profile/data/models/user_profile_response_model.dart';
import 'package:bite_front_end/features/profile/data/models/user_profile_update_model.dart';
import 'package:bite_front_end/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfileResponseModel>(
      ProfileNotifier.new,
    );

class ProfileNotifier extends AsyncNotifier<UserProfileResponseModel> {
  late final ProfileRepository _repository;

  @override
  FutureOr<UserProfileResponseModel> build() async {
    _repository = ref.watch(profileRepositoryProvider);
    return await _repository.getProfile();
  }

  Future<void> fetchProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getProfile());
  }

  Future<bool> updateProfile(UserProfileUpdateModel request) async {
    try {
      final updatedProfile = await _repository.updateProfile(request);
      state = AsyncValue.data(updatedProfile);

      // Invalidate dashboard provider so calorie and macro targets refresh seamlessly
      ref.invalidate(dailyDashboardProvider);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}
