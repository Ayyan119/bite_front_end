import 'package:bite_front_end/features/meals/data/datasources/meals_remote_data_source.dart';
import 'package:bite_front_end/features/meals/data/models/meal_analysis_response_model.dart';
import 'package:bite_front_end/features/meals/data/models/meal_confirm_request_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class MockDioPost extends Fake implements Dio {
  Response? mockResponse;
  DioException? mockException;
  String? lastPath;
  dynamic lastData;

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    lastPath = path;
    lastData = data;

    if (mockException != null) {
      throw mockException!;
    }

    return mockResponse as Response<T>;
  }
}

void main() {
  late MockDioPost mockDio;
  late MealsRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDioPost();
    dataSource = MealsRemoteDataSourceImpl(mockDio);
  });

  group('MealsRemoteDataSourceImpl', () {
    test(
      'analyzeMeal JSON request returns MealAnalysisResponseModel on 200 OK',
      () async {
        mockDio.mockResponse = Response(
          statusCode: 200,
          data: {
            'detected_items': [
              {
                'food_name': 'Banana',
                'fdc_id': 2012128,
                'portion_amount': 2.0,
                'portion_unit': 'medium banana',
                'gram_weight': 236.0,
                'calories': 210.04,
                'protein_g': 2.57,
                'carbs_g': 53.81,
                'fat_g': 0.78,
                'is_fallback': false,
                'raw_usda_nutrients': {},
              },
            ],
            'meal_type': 'breakfast',
            'meal_type_source': 'caption_explicit',
            'total_calories': 210.04,
            'total_protein_g': 2.57,
            'total_carbs_g': 53.81,
            'total_fat_g': 0.78,
            'aggregated_nutrients': {},
            'confidence_score': 1.0,
            'warnings': [],
          },
          requestOptions: RequestOptions(path: '/meals/analyze'),
        );

        final result = await dataSource.analyzeMeal(
          userCaption: '2 bananas',
          mealType: 'breakfast',
        );

        expect(result.mealType, 'breakfast');
        expect(result.detectedItems.length, 1);
        expect(result.detectedItems.first.foodName, 'Banana');
        expect(mockDio.lastPath, '/meals/analyze');
      },
    );

    test(
      'confirmMeal returns MealConfirmResponseModel on 201 Created',
      () async {
        mockDio.mockResponse = Response(
          statusCode: 201,
          data: {
            'meal_id': 'meal_123',
            'user_id': 'user_123',
            'logged_at': '2026-08-25 10:00:00+00',
            'meal_type': 'breakfast',
            'total_calories': 210.04,
            'total_protein_g': 2.57,
            'total_carbs_g': 53.81,
            'total_fat_g': 0.78,
            'item_count': 1,
          },
          requestOptions: RequestOptions(path: '/meals/confirm'),
        );

        final request = MealConfirmRequestModel(
          mealType: 'breakfast',
          items: [
            const DetectedItemModel(
              foodName: 'Banana',
              portionAmount: 2.0,
              portionUnit: 'medium banana',
              gramWeight: 236.0,
              calories: 210.04,
              proteinG: 2.57,
              carbsG: 53.81,
              fatG: 0.78,
              isFallback: false,
              rawUsdaNutrients: {},
            ),
          ],
        );

        final result = await dataSource.confirmMeal(request);

        expect(result.mealId, 'meal_123');
        expect(result.totalCalories, 210.04);
        expect(mockDio.lastPath, '/meals/confirm');
      },
    );
  });
}
