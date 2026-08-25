class DevTokenRequestModel {
  final String email;
  final String? userId;

  const DevTokenRequestModel({required this.email, this.userId});

  Map<String, dynamic> toJson() {
    return {'email': email, 'user_id': userId};
  }

  factory DevTokenRequestModel.fromJson(Map<String, dynamic> json) {
    return DevTokenRequestModel(
      email: json['email'] as String? ?? '',
      userId: json['user_id'] as String?,
    );
  }
}
