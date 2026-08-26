class RegisterRequestModel {
  final String email;
  final String password;
  final String displayName;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final String? gender;
  final String? activityLevel;
  final String? primaryGoal;

  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.displayName,
    this.age,
    this.heightCm,
    this.weightKg,
    this.gender,
    this.activityLevel,
    this.primaryGoal,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email,
      'password': password,
      'display_name': displayName,
    };
    if (age != null) map['age'] = age;
    if (heightCm != null) map['height_cm'] = heightCm;
    if (weightKg != null) map['weight_kg'] = weightKg;
    if (gender != null && gender!.isNotEmpty) map['gender'] = gender;
    if (activityLevel != null && activityLevel!.isNotEmpty) {
      map['activity_level'] = activityLevel;
    }
    if (primaryGoal != null && primaryGoal!.isNotEmpty) {
      map['primary_goal'] = primaryGoal;
    }
    return map;
  }

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      gender: json['gender'] as String?,
      activityLevel: json['activity_level'] as String?,
      primaryGoal: json['primary_goal'] as String?,
    );
  }
}
