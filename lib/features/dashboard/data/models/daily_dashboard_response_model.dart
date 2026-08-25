class MacroProgressModel {
  final double target;
  final double consumed;
  final double remaining;

  const MacroProgressModel({
    required this.target,
    required this.consumed,
    required this.remaining,
  });

  factory MacroProgressModel.fromJson(Map<String, dynamic> json) {
    return MacroProgressModel(
      target: (json['target'] as num?)?.toDouble() ?? 0.0,
      consumed: (json['consumed'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'target': target, 'consumed': consumed, 'remaining': remaining};
  }
}

class LoggedMealSummaryModel {
  final String mealId;
  final String mealType;
  final String? userCaption;
  final String? imageUrl;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String loggedAt;

  const LoggedMealSummaryModel({
    required this.mealId,
    required this.mealType,
    this.userCaption,
    this.imageUrl,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.loggedAt,
  });

  factory LoggedMealSummaryModel.fromJson(Map<String, dynamic> json) {
    return LoggedMealSummaryModel(
      mealId: json['meal_id'] as String? ?? '',
      mealType: json['meal_type'] as String? ?? 'snack',
      userCaption: json['user_caption'] as String?,
      imageUrl: json['image_url'] as String?,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fatG: (json['fat_g'] as num?)?.toDouble() ?? 0.0,
      loggedAt: json['logged_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_id': mealId,
      'meal_type': mealType,
      'user_caption': userCaption,
      'image_url': imageUrl,
      'calories': calories,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
      'logged_at': loggedAt,
    };
  }
}

class DailyDashboardResponseModel {
  final String date;
  final double targetCalories;
  final double consumedCalories;
  final double remainingCalories;
  final MacroProgressModel protein;
  final MacroProgressModel carbs;
  final MacroProgressModel fat;
  final List<LoggedMealSummaryModel> meals;
  final Map<String, double> topMicronutrients;

  const DailyDashboardResponseModel({
    required this.date,
    required this.targetCalories,
    required this.consumedCalories,
    required this.remainingCalories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.meals,
    required this.topMicronutrients,
  });

  factory DailyDashboardResponseModel.fromJson(Map<String, dynamic> json) {
    final microRaw = json['top_micronutrients'] != null
        ? Map<String, dynamic>.from(json['top_micronutrients'] as Map)
        : <String, dynamic>{};
    final microMap = microRaw.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return DailyDashboardResponseModel(
      date: json['date'] as String? ?? '',
      targetCalories: (json['target_calories'] as num?)?.toDouble() ?? 0.0,
      consumedCalories: (json['consumed_calories'] as num?)?.toDouble() ?? 0.0,
      remainingCalories:
          (json['remaining_calories'] as num?)?.toDouble() ?? 0.0,
      protein: MacroProgressModel.fromJson(
        json['protein'] as Map<String, dynamic>? ?? {},
      ),
      carbs: MacroProgressModel.fromJson(
        json['carbs'] as Map<String, dynamic>? ?? {},
      ),
      fat: MacroProgressModel.fromJson(
        json['fat'] as Map<String, dynamic>? ?? {},
      ),
      meals:
          (json['meals'] as List<dynamic>?)
              ?.map(
                (e) =>
                    LoggedMealSummaryModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      topMicronutrients: microMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'target_calories': targetCalories,
      'consumed_calories': consumedCalories,
      'remaining_calories': remainingCalories,
      'protein': protein.toJson(),
      'carbs': carbs.toJson(),
      'fat': fat.toJson(),
      'meals': meals.map((m) => m.toJson()).toList(),
      'top_micronutrients': topMicronutrients,
    };
  }
}
