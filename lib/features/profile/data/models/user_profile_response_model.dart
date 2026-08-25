class UserProfileResponseModel {
  final String id;
  final String displayName;
  final double heightCm;
  final double weightKg;
  final int age;
  final String gender;
  final String activityLevel;
  final String primaryGoal;
  final double bmr;
  final double tdee;
  final double targetCalories;
  final double targetProteinG;
  final double targetCarbsG;
  final double targetFatG;
  final Map<String, dynamic> targetMicronutrients;

  const UserProfileResponseModel({
    required this.id,
    required this.displayName,
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.primaryGoal,
    required this.bmr,
    required this.tdee,
    required this.targetCalories,
    required this.targetProteinG,
    required this.targetCarbsG,
    required this.targetFatG,
    required this.targetMicronutrients,
  });

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UserProfileResponseModel(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 0.0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? 'male',
      activityLevel: json['activity_level'] as String? ?? 'moderate',
      primaryGoal: json['primary_goal'] as String? ?? 'maintenance',
      bmr: (json['bmr'] as num?)?.toDouble() ?? 0.0,
      tdee: (json['tdee'] as num?)?.toDouble() ?? 0.0,
      targetCalories: (json['target_calories'] as num?)?.toDouble() ?? 0.0,
      targetProteinG: (json['target_protein_g'] as num?)?.toDouble() ?? 0.0,
      targetCarbsG: (json['target_carbs_g'] as num?)?.toDouble() ?? 0.0,
      targetFatG: (json['target_fat_g'] as num?)?.toDouble() ?? 0.0,
      targetMicronutrients: json['target_micronutrients'] != null
          ? Map<String, dynamic>.from(json['target_micronutrients'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'age': age,
      'gender': gender,
      'activity_level': activityLevel,
      'primary_goal': primaryGoal,
      'bmr': bmr,
      'tdee': tdee,
      'target_calories': targetCalories,
      'target_protein_g': targetProteinG,
      'target_carbs_g': targetCarbsG,
      'target_fat_g': targetFatG,
      'target_micronutrients': targetMicronutrients,
    };
  }
}
