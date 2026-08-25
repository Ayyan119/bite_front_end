class RegisterRequestModel {
  final String email;
  final String password;
  final String displayName;
  final int age;
  final double heightCm;
  final double weightKg;
  final String gender;
  final String activityLevel;
  final String primaryGoal;

  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.displayName,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.gender,
    required this.activityLevel,
    required this.primaryGoal,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'display_name': displayName,
      'age': age,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'gender': gender,
      'activity_level': activityLevel,
      'primary_goal': primaryGoal,
    };
  }

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 0.0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      gender: json['gender'] as String? ?? 'male',
      activityLevel: json['activity_level'] as String? ?? 'moderate',
      primaryGoal: json['primary_goal'] as String? ?? 'maintenance',
    );
  }
}
