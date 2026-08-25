import 'package:bite_front_end/features/profile/data/models/user_profile_response_model.dart';
import 'package:bite_front_end/features/profile/data/models/user_profile_update_model.dart';
import 'package:bite_front_end/features/profile/data/repositories/profile_repository.dart';
import 'package:bite_front_end/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeProfileRepository implements ProfileRepository {
  UserProfileResponseModel mockProfile = const UserProfileResponseModel(
    id: 'user_123',
    displayName: 'Alex Morgan',
    heightCm: 178.0,
    weightKg: 75.0,
    age: 28,
    gender: 'male',
    activityLevel: 'moderate',
    primaryGoal: 'muscle_gain',
    bmr: 1720.0,
    tdee: 2666.0,
    targetCalories: 2400.0,
    targetProteinG: 180.0,
    targetCarbsG: 250.0,
    targetFatG: 70.0,
    targetMicronutrients: {},
  );

  @override
  Future<UserProfileResponseModel> getProfile() async => mockProfile;

  @override
  Future<UserProfileResponseModel> updateProfile(
    UserProfileUpdateModel request,
  ) async {
    mockProfile = UserProfileResponseModel(
      id: mockProfile.id,
      displayName: request.displayName ?? mockProfile.displayName,
      heightCm: request.heightCm ?? mockProfile.heightCm,
      weightKg: request.weightKg ?? mockProfile.weightKg,
      age: request.age ?? mockProfile.age,
      gender: request.gender ?? mockProfile.gender,
      activityLevel: request.activityLevel ?? mockProfile.activityLevel,
      primaryGoal: request.primaryGoal ?? mockProfile.primaryGoal,
      bmr: 1800.0,
      tdee: 2750.0,
      targetCalories: 2500.0,
      targetProteinG: 190.0,
      targetCarbsG: 260.0,
      targetFatG: 75.0,
      targetMicronutrients: {},
    );
    return mockProfile;
  }
}

void main() {
  late ProviderContainer container;
  late FakeProfileRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeProfileRepository();
    container = ProviderContainer(
      overrides: [profileRepositoryProvider.overrideWithValue(fakeRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('build fetches initial profile successfully', () async {
    final profile = await container.read(profileNotifierProvider.future);
    expect(profile.displayName, 'Alex Morgan');
    expect(profile.bmr, 1720.0);
  });

  test('updateProfile updates state with recalculated values', () async {
    // Await initial build
    await container.read(profileNotifierProvider.future);

    final notifier = container.read(profileNotifierProvider.notifier);
    final success = await notifier.updateProfile(
      const UserProfileUpdateModel(weightKg: 78.0, activityLevel: 'active'),
    );

    expect(success, isTrue);

    final state = container.read(profileNotifierProvider);
    expect(state.value?.weightKg, 78.0);
    expect(state.value?.bmr, 1800.0);
    expect(state.value?.targetCalories, 2500.0);
  });
}
