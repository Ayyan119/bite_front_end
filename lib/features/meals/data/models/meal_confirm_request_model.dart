import 'meal_analysis_response_model.dart';

class MealConfirmRequestModel {
  final String mealType;
  final String? userCaption;
  final String? imageUrl;
  final List<DetectedItemModel> items;

  const MealConfirmRequestModel({
    required this.mealType,
    this.userCaption,
    this.imageUrl,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'meal_type': mealType,
      'user_caption': userCaption,
      'image_url': imageUrl,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  factory MealConfirmRequestModel.fromJson(Map<String, dynamic> json) {
    return MealConfirmRequestModel(
      mealType: json['meal_type'] as String? ?? 'snack',
      userCaption: json['user_caption'] as String?,
      imageUrl: json['image_url'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => DetectedItemModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
