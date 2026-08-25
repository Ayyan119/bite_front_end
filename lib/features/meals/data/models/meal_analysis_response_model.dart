class DetectedItemModel {
  final String foodName;
  final int? fdcId;
  final double portionAmount;
  final String portionUnit;
  final double gramWeight;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final bool isFallback;
  final Map<String, dynamic> rawUsdaNutrients;

  const DetectedItemModel({
    required this.foodName,
    this.fdcId,
    required this.portionAmount,
    required this.portionUnit,
    required this.gramWeight,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.isFallback,
    required this.rawUsdaNutrients,
  });

  factory DetectedItemModel.fromJson(Map<String, dynamic> json) {
    return DetectedItemModel(
      foodName: json['food_name'] as String? ?? '',
      fdcId: (json['fdc_id'] as num?)?.toInt(),
      portionAmount: (json['portion_amount'] as num?)?.toDouble() ?? 1.0,
      portionUnit: json['portion_unit'] as String? ?? 'serving',
      gramWeight: (json['gram_weight'] as num?)?.toDouble() ?? 0.0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fatG: (json['fat_g'] as num?)?.toDouble() ?? 0.0,
      isFallback: json['is_fallback'] as bool? ?? false,
      rawUsdaNutrients: json['raw_usda_nutrients'] != null
          ? Map<String, dynamic>.from(json['raw_usda_nutrients'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_name': foodName,
      'fdc_id': fdcId,
      'portion_amount': portionAmount,
      'portion_unit': portionUnit,
      'gram_weight': gramWeight,
      'calories': calories,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
      'is_fallback': isFallback,
      'raw_usda_nutrients': rawUsdaNutrients,
    };
  }
}

class MealAnalyzeRequestModel {
  final String? imageUrl;
  final String? userCaption;
  final String? mealType;

  const MealAnalyzeRequestModel({
    this.imageUrl,
    this.userCaption,
    this.mealType,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (imageUrl != null) map['image_url'] = imageUrl;
    if (userCaption != null) map['user_caption'] = userCaption;
    if (mealType != null) map['meal_type'] = mealType;
    return map;
  }

  factory MealAnalyzeRequestModel.fromJson(Map<String, dynamic> json) {
    return MealAnalyzeRequestModel(
      imageUrl: json['image_url'] as String?,
      userCaption: json['user_caption'] as String?,
      mealType: json['meal_type'] as String?,
    );
  }
}

class MealAnalysisResponseModel {
  final List<DetectedItemModel> detectedItems;
  final String mealType;
  final String mealTypeSource;
  final double totalCalories;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;
  final Map<String, double> aggregatedNutrients;
  final double confidenceScore;
  final List<String> warnings;

  const MealAnalysisResponseModel({
    required this.detectedItems,
    required this.mealType,
    required this.mealTypeSource,
    required this.totalCalories,
    required this.totalProteinG,
    required this.totalCarbsG,
    required this.totalFatG,
    required this.aggregatedNutrients,
    required this.confidenceScore,
    required this.warnings,
  });

  factory MealAnalysisResponseModel.fromJson(Map<String, dynamic> json) {
    final aggRaw = json['aggregated_nutrients'] != null
        ? Map<String, dynamic>.from(json['aggregated_nutrients'] as Map)
        : <String, dynamic>{};
    final aggMap = aggRaw.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return MealAnalysisResponseModel(
      detectedItems:
          (json['detected_items'] as List<dynamic>?)
              ?.map(
                (e) => DetectedItemModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      mealType: json['meal_type'] as String? ?? 'snack',
      mealTypeSource: json['meal_type_source'] as String? ?? 'inferred',
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0.0,
      totalProteinG: (json['total_protein_g'] as num?)?.toDouble() ?? 0.0,
      totalCarbsG: (json['total_carbs_g'] as num?)?.toDouble() ?? 0.0,
      totalFatG: (json['total_fat_g'] as num?)?.toDouble() ?? 0.0,
      aggregatedNutrients: aggMap,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 1.0,
      warnings:
          (json['warnings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detected_items': detectedItems.map((e) => e.toJson()).toList(),
      'meal_type': mealType,
      'meal_type_source': mealTypeSource,
      'total_calories': totalCalories,
      'total_protein_g': totalProteinG,
      'total_carbs_g': totalCarbsG,
      'total_fat_g': totalFatG,
      'aggregated_nutrients': aggregatedNutrients,
      'confidence_score': confidenceScore,
      'warnings': warnings,
    };
  }
}
