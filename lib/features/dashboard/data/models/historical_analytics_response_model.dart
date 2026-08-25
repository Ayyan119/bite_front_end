class DailyHistoryItemModel {
  final String date;
  final int mealCount;
  final double totalCalories;
  final double targetCalories;
  final double totalProteinG;
  final double targetProteinG;
  final double totalCarbsG;
  final double targetCarbsG;
  final double totalFatG;
  final double targetFatG;
  final String goalStatus;

  const DailyHistoryItemModel({
    required this.date,
    required this.mealCount,
    required this.totalCalories,
    required this.targetCalories,
    required this.totalProteinG,
    required this.targetProteinG,
    required this.totalCarbsG,
    required this.targetCarbsG,
    required this.totalFatG,
    required this.targetFatG,
    required this.goalStatus,
  });

  factory DailyHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return DailyHistoryItemModel(
      date: json['date'] as String? ?? '',
      mealCount: (json['meal_count'] as num?)?.toInt() ?? 0,
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0.0,
      targetCalories: (json['target_calories'] as num?)?.toDouble() ?? 0.0,
      totalProteinG: (json['total_protein_g'] as num?)?.toDouble() ?? 0.0,
      targetProteinG: (json['target_protein_g'] as num?)?.toDouble() ?? 0.0,
      totalCarbsG: (json['total_carbs_g'] as num?)?.toDouble() ?? 0.0,
      targetCarbsG: (json['target_carbs_g'] as num?)?.toDouble() ?? 0.0,
      totalFatG: (json['total_fat_g'] as num?)?.toDouble() ?? 0.0,
      targetFatG: (json['target_fat_g'] as num?)?.toDouble() ?? 0.0,
      goalStatus: json['goal_status'] as String? ?? 'under',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'meal_count': mealCount,
      'total_calories': totalCalories,
      'target_calories': targetCalories,
      'total_protein_g': totalProteinG,
      'target_protein_g': targetProteinG,
      'total_carbs_g': totalCarbsG,
      'target_carbs_g': targetCarbsG,
      'total_fat_g': totalFatG,
      'target_fat_g': targetFatG,
      'goal_status': goalStatus,
    };
  }
}

class HistoricalAnalyticsResponseModel {
  final String userId;
  final int totalDaysLogged;
  final List<DailyHistoryItemModel> history;

  const HistoricalAnalyticsResponseModel({
    required this.userId,
    required this.totalDaysLogged,
    required this.history,
  });

  factory HistoricalAnalyticsResponseModel.fromJson(Map<String, dynamic> json) {
    return HistoricalAnalyticsResponseModel(
      userId: json['user_id'] as String? ?? '',
      totalDaysLogged: (json['total_days_logged'] as num?)?.toInt() ?? 0,
      history:
          (json['history'] as List<dynamic>?)
              ?.map(
                (e) =>
                    DailyHistoryItemModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_days_logged': totalDaysLogged,
      'history': history.map((item) => item.toJson()).toList(),
    };
  }
}
