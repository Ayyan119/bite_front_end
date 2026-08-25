import 'package:bite_front_end/features/profile/data/models/user_profile_response_model.dart';
import 'package:bite_front_end/features/profile/data/models/user_profile_update_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleProfileJson = {
    'id': 'user_123',
    'display_name': 'Alex Morgan',
    'height_cm': 178.0,
    'weight_kg': 75.0,
    'age': 28,
    'gender': 'male',
    'activity_level': 'moderate',
    'primary_goal': 'muscle_gain',
    'bmr': 1720.0,
    'tdee': 2666.0,
    'target_calories': 2400.0,
    'target_protein_g': 180.0,
    'target_carbs_g': 250.0,
    'target_fat_g': 70.0,
    'target_micronutrients': {},
  };

  test('UserProfileResponseModel.fromJson parses correctly', () {
    final model = UserProfileResponseModel.fromJson(sampleProfileJson);
    expect(model.id, 'user_123');
    expect(model.displayName, 'Alex Morgan');
    expect(model.bmr, 1720.0);
    expect(model.tdee, 2666.0);
  });

  test('UserProfileUpdateModel.toJson outputs correct map', () {
    const update = UserProfileUpdateModel(
      displayName: 'Alex Morgan',
      heightCm: 180.0,
      weightKg: 77.0,
      age: 29,
      gender: 'male',
      activityLevel: 'active',
      primaryGoal: 'muscle_gain',
    );

    final json = update.toJson();
    expect(json['display_name'], 'Alex Morgan');
    expect(json['height_cm'], 180.0);
    expect(json['activity_level'], 'active');
  });
}
