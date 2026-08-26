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
    final height = (json['height_cm'] as num?)?.toDouble() ?? 0.0;
    final weight = (json['weight_kg'] as num?)?.toDouble() ?? 0.0;
    final userAge = (json['age'] as num?)?.toInt() ?? 0;
    final hasBodyMetrics = height > 0 && weight > 0 && userAge > 0;

    final rawCalories = (json['target_calories'] as num?)?.toDouble() ?? 0.0;
    final rawProtein = (json['target_protein_g'] as num?)?.toDouble() ?? 0.0;
    final rawCarbs = (json['target_carbs_g'] as num?)?.toDouble() ?? 0.0;
    final rawFat = (json['target_fat_g'] as num?)?.toDouble() ?? 0.0;
    final rawTdee = (json['tdee'] as num?)?.toDouble() ?? 0.0;

    return UserProfileResponseModel(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      heightCm: height,
      weightKg: weight,
      age: userAge,
      gender: json['gender'] as String? ?? '',
      activityLevel: json['activity_level'] as String? ?? '',
      primaryGoal: json['primary_goal'] as String? ?? '',
      bmr: hasBodyMetrics ? ((json['bmr'] as num?)?.toDouble() ?? 0.0) : 0.0,
      tdee: (rawTdee > 0) ? rawTdee : 2000.0,
      targetCalories: (rawCalories > 0) ? rawCalories : 2000.0,
      targetProteinG: (rawProtein > 0) ? rawProtein : 50.0,
      targetCarbsG: (rawCarbs > 0) ? rawCarbs : 275.0,
      targetFatG: (rawFat > 0) ? rawFat : 67.0,
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
