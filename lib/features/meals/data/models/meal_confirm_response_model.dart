class MealConfirmResponseModel {
  final String mealId;
  final String userId;
  final String loggedAt;
  final String mealType;
  final double totalCalories;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;
  final int itemCount;

  const MealConfirmResponseModel({
    required this.mealId,
    required this.userId,
    required this.loggedAt,
    required this.mealType,
    required this.totalCalories,
    required this.totalProteinG,
    required this.totalCarbsG,
    required this.totalFatG,
    required this.itemCount,
  });

  factory MealConfirmResponseModel.fromJson(Map<String, dynamic> json) {
    return MealConfirmResponseModel(
      mealId: json['meal_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      loggedAt: json['logged_at'] as String? ?? '',
      mealType: json['meal_type'] as String? ?? 'snack',
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0.0,
      totalProteinG: (json['total_protein_g'] as num?)?.toDouble() ?? 0.0,
      totalCarbsG: (json['total_carbs_g'] as num?)?.toDouble() ?? 0.0,
      totalFatG: (json['total_fat_g'] as num?)?.toDouble() ?? 0.0,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_id': mealId,
      'user_id': userId,
      'logged_at': loggedAt,
      'meal_type': mealType,
      'total_calories': totalCalories,
      'total_protein_g': totalProteinG,
      'total_carbs_g': totalCarbsG,
      'total_fat_g': totalFatG,
      'item_count': itemCount,
    };
  }
}
