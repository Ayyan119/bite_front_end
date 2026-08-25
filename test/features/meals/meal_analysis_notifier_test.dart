import 'package:bite_front_end/features/meals/data/models/meal_analysis_response_model.dart';
import 'package:bite_front_end/features/meals/data/models/meal_confirm_request_model.dart';
import 'package:bite_front_end/features/meals/data/models/meal_confirm_response_model.dart';
import 'package:bite_front_end/features/meals/data/repositories/meals_repository.dart';
import 'package:bite_front_end/features/meals/presentation/providers/meal_analysis_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

class FakeMealsRepository implements MealsRepository {
  MealAnalysisResponseModel? mockAnalysis;
  MealConfirmResponseModel? mockConfirm;
  bool shouldThrow = false;

  @override
  Future<MealAnalysisResponseModel> analyzeMeal({
    XFile? file,
    String? imageUrl,
    String? userCaption,
    String? mealType,
  }) async {
    if (shouldThrow) throw Exception('API Error');
    return mockAnalysis ??
        const MealAnalysisResponseModel(
          detectedItems: [
            DetectedItemModel(
              foodName: 'Apple',
              portionAmount: 1.0,
              portionUnit: 'medium apple',
              gramWeight: 182.0,
              calories: 95.0,
              proteinG: 0.5,
              carbsG: 25.0,
              fatG: 0.3,
              isFallback: false,
              rawUsdaNutrients: {},
            ),
          ],
          mealType: 'snack',
          mealTypeSource: 'inferred',
          totalCalories: 95.0,
          totalProteinG: 0.5,
          totalCarbsG: 25.0,
          totalFatG: 0.3,
          aggregatedNutrients: {},
          confidenceScore: 1.0,
          warnings: [],
        );
  }

  @override
  Future<MealConfirmResponseModel> confirmMeal(
    MealConfirmRequestModel request,
  ) async {
    if (shouldThrow) throw Exception('Confirm Error');
    return mockConfirm ??
        const MealConfirmResponseModel(
          mealId: 'm123',
          userId: 'u123',
          loggedAt: '2026-08-25',
          mealType: 'snack',
          totalCalories: 95.0,
          totalProteinG: 0.5,
          totalCarbsG: 25.0,
          totalFatG: 0.3,
          itemCount: 1,
        );
  }
}

void main() {
  late FakeMealsRepository fakeRepository;
  late ProviderContainer container;

  setUp(() {
    fakeRepository = FakeMealsRepository();
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('MealAnalysisNotifier', () {
    test('initial state is correct', () {
      final notifier = MealAnalysisNotifier(
        fakeRepository,
        container.read(providerContainerProvider),
      );
      expect(notifier.state.status, MealAnalysisStatus.initial);
      expect(notifier.state.items, isEmpty);
      expect(notifier.state.totalCalories, 0.0);
    });

    test('updateItemPortion scales calories and macros proportionally', () {
      final notifier = MealAnalysisNotifier(
        fakeRepository,
        container.read(providerContainerProvider),
      );
      notifier.addItem(
        const DetectedItemModel(
          foodName: 'Banana',
          portionAmount: 1.0,
          portionUnit: 'banana',
          gramWeight: 100.0,
          calories: 100.0,
          proteinG: 1.0,
          carbsG: 25.0,
          fatG: 0.5,
          isFallback: false,
          rawUsdaNutrients: {},
        ),
      );

      expect(notifier.state.totalCalories, 100.0);

      // Scale up portion from 1.0 to 2.0
      notifier.updateItemPortion(0, 2.0);

      expect(notifier.state.items.first.portionAmount, 2.0);
      expect(notifier.state.items.first.calories, 200.0);
      expect(notifier.state.items.first.proteinG, 2.0);
      expect(notifier.state.items.first.carbsG, 50.0);
      expect(notifier.state.totalCalories, 200.0);
    });

    test('removeItem and addItem update totals correctly', () {
      final notifier = MealAnalysisNotifier(
        fakeRepository,
        container.read(providerContainerProvider),
      );
      const item1 = DetectedItemModel(
        foodName: 'Egg',
        portionAmount: 1.0,
        portionUnit: 'large egg',
        gramWeight: 50.0,
        calories: 70.0,
        proteinG: 6.0,
        carbsG: 0.5,
        fatG: 5.0,
        isFallback: false,
        rawUsdaNutrients: {},
      );

      notifier.addItem(item1);
      expect(notifier.state.items.length, 1);
      expect(notifier.state.totalCalories, 70.0);

      notifier.removeItem(0);
      expect(notifier.state.items.length, 0);
      expect(notifier.state.totalCalories, 0.0);
    });

    test('analyzeMeal sets review status on success', () async {
      final notifier = MealAnalysisNotifier(
        fakeRepository,
        container.read(providerContainerProvider),
      );
      notifier.setCaption('One apple');

      await notifier.analyzeMeal();

      expect(notifier.state.status, MealAnalysisStatus.review);
      expect(notifier.state.items.length, 1);
      expect(notifier.state.items.first.foodName, 'Apple');
    });
  });
}

final providerContainerProvider = Provider<Ref>((ref) => ref);
