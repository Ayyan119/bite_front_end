class AuthResponseModel {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String userId;
  final String email;
  final String? displayName;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final String? gender;
  final double? bmr;
  final double? tdee;
  final double? targetCalories;

  const AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.userId,
    required this.email,
    this.displayName,
    this.age,
    this.heightCm,
    this.weightKg,
    this.gender,
    this.bmr,
    this.tdee,
    this.targetCalories,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 86400,
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String?,
      age: (json['age'] as num?)?.toInt(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      gender: json['gender'] as String?,
      bmr: (json['bmr'] as num?)?.toDouble(),
      tdee: (json['tdee'] as num?)?.toDouble(),
      targetCalories: (json['target_calories'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user_id': userId,
      'email': email,
      'display_name': displayName,
      'age': age,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'gender': gender,
      'bmr': bmr,
      'tdee': tdee,
      'target_calories': targetCalories,
    };
  }
}
