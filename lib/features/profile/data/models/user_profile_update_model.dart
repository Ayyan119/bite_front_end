class UserProfileUpdateModel {
  final String? displayName;
  final double? heightCm;
  final double? weightKg;
  final int? age;
  final String? gender;
  final String? activityLevel;
  final String? primaryGoal;

  const UserProfileUpdateModel({
    this.displayName,
    this.heightCm,
    this.weightKg,
    this.age,
    this.gender,
    this.activityLevel,
    this.primaryGoal,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (displayName != null) map['display_name'] = displayName;
    if (heightCm != null) map['height_cm'] = heightCm;
    if (weightKg != null) map['weight_kg'] = weightKg;
    if (age != null) map['age'] = age;
    if (gender != null) map['gender'] = gender;
    if (activityLevel != null) map['activity_level'] = activityLevel;
    if (primaryGoal != null) map['primary_goal'] = primaryGoal;
    return map;
  }

  factory UserProfileUpdateModel.fromJson(Map<String, dynamic> json) {
    return UserProfileUpdateModel(
      displayName: json['display_name'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      activityLevel: json['activity_level'] as String?,
      primaryGoal: json['primary_goal'] as String?,
    );
  }
}
