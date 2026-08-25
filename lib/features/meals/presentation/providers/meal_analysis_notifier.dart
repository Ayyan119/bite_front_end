import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../data/models/meal_analysis_response_model.dart';
import '../../data/models/meal_confirm_request_model.dart';
import '../../data/models/meal_confirm_response_model.dart';
import '../../data/repositories/meals_repository.dart';

enum MealAnalysisStatus {
  initial,
  analyzing,
  review,
  committing,
  success,
  failure,
}

class MealAnalysisState {
  final MealAnalysisStatus status;
  final XFile? selectedFile;
  final String? imageUrl;
  final String userCaption;
  final String selectedMealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final List<DetectedItemModel> items;
  final String? errorMessage;
  final MealConfirmResponseModel? lastConfirmedMeal;

  const MealAnalysisState({
    this.status = MealAnalysisStatus.initial,
    this.selectedFile,
    this.imageUrl,
    this.userCaption = '',
    this.selectedMealType = 'snack',
    this.items = const [],
    this.errorMessage,
    this.lastConfirmedMeal,
  });

  MealAnalysisState copyWith({
    MealAnalysisStatus? status,
    XFile? Function()? selectedFile,
    String? Function()? imageUrl,
    String? userCaption,
    String? selectedMealType,
    List<DetectedItemModel>? items,
    String? Function()? errorMessage,
    MealConfirmResponseModel? Function()? lastConfirmedMeal,
  }) {
    return MealAnalysisState(
      status: status ?? this.status,
      selectedFile: selectedFile != null ? selectedFile() : this.selectedFile,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      userCaption: userCaption ?? this.userCaption,
      selectedMealType: selectedMealType ?? this.selectedMealType,
      items: items ?? this.items,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      lastConfirmedMeal: lastConfirmedMeal != null
          ? lastConfirmedMeal()
          : this.lastConfirmedMeal,
    );
  }

  double get totalCalories => items.fold(0.0, (sum, i) => sum + i.calories);
  double get totalProtein => items.fold(0.0, (sum, i) => sum + i.proteinG);
  double get totalCarbs => items.fold(0.0, (sum, i) => sum + i.carbsG);
  double get totalFat => items.fold(0.0, (sum, i) => sum + i.fatG);
}

class MealAnalysisNotifier extends StateNotifier<MealAnalysisState> {
  final MealsRepository _repository;
  final Ref _ref;

  MealAnalysisNotifier(this._repository, this._ref)
    : super(const MealAnalysisState());

  void setSelectedFile(XFile? file) {
    state = state.copyWith(selectedFile: () => file, errorMessage: () => null);
  }

  void setImageUrl(String? url) {
    state = state.copyWith(imageUrl: () => url, errorMessage: () => null);
  }

  void setCaption(String caption) {
    state = state.copyWith(userCaption: caption, errorMessage: () => null);
  }

  void setMealType(String mealType) {
    state = state.copyWith(
      selectedMealType: mealType,
      errorMessage: () => null,
    );
  }

  Future<void> analyzeMeal() async {
    if (state.selectedFile == null &&
        (state.imageUrl == null || state.imageUrl!.trim().isEmpty) &&
        state.userCaption.trim().isEmpty) {
      state = state.copyWith(
        status: MealAnalysisStatus.failure,
        errorMessage: () =>
            'Please pick an image or enter a caption to analyze',
      );
      return;
    }

    state = state.copyWith(
      status: MealAnalysisStatus.analyzing,
      errorMessage: () => null,
    );

    try {
      final response = await _repository.analyzeMeal(
        file: state.selectedFile,
        imageUrl: state.imageUrl,
        userCaption: state.userCaption,
        mealType: state.selectedMealType,
      );

      state = state.copyWith(
        status: MealAnalysisStatus.review,
        items: response.detectedItems,
        selectedMealType: response.mealType.isNotEmpty
            ? response.mealType
            : state.selectedMealType,
      );
    } catch (e) {
      state = state.copyWith(
        status: MealAnalysisStatus.failure,
        errorMessage: () => e.toString().replaceFirst('ServerFailure: ', ''),
      );
    }
  }

  void updateItemPortion(int index, double newAmount) {
    if (index < 0 || index >= state.items.length) return;
    if (newAmount <= 0) return;

    final oldItem = state.items[index];
    if (oldItem.portionAmount <= 0) return;

    final ratio = newAmount / oldItem.portionAmount;

    final newItem = DetectedItemModel(
      foodName: oldItem.foodName,
      fdcId: oldItem.fdcId,
      portionAmount: newAmount,
      portionUnit: oldItem.portionUnit,
      gramWeight: oldItem.gramWeight * ratio,
      calories: oldItem.calories * ratio,
      proteinG: oldItem.proteinG * ratio,
      carbsG: oldItem.carbsG * ratio,
      fatG: oldItem.fatG * ratio,
      isFallback: oldItem.isFallback,
      rawUsdaNutrients: oldItem.rawUsdaNutrients,
    );

    final updated = List<DetectedItemModel>.from(state.items);
    updated[index] = newItem;

    state = state.copyWith(items: updated);
  }

  void removeItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final updated = List<DetectedItemModel>.from(state.items)..removeAt(index);
    state = state.copyWith(items: updated);
  }

  void addItem(DetectedItemModel item) {
    final updated = List<DetectedItemModel>.from(state.items)..add(item);
    state = state.copyWith(items: updated);
  }

  Future<bool> confirmMeal() async {
    if (state.items.isEmpty) {
      state = state.copyWith(
        status: MealAnalysisStatus.failure,
        errorMessage: () => 'Cannot confirm a meal with no food items',
      );
      return false;
    }

    state = state.copyWith(
      status: MealAnalysisStatus.committing,
      errorMessage: () => null,
    );

    try {
      final request = MealConfirmRequestModel(
        mealType: state.selectedMealType,
        userCaption: state.userCaption.isNotEmpty ? state.userCaption : null,
        imageUrl: state.imageUrl,
        items: state.items,
      );

      final response = await _repository.confirmMeal(request);

      _ref.invalidate(dailyDashboardProvider);
      _ref.invalidate(historicalAnalyticsProvider);

      state = state.copyWith(
        status: MealAnalysisStatus.success,
        lastConfirmedMeal: () => response,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: MealAnalysisStatus.failure,
        errorMessage: () => e.toString().replaceFirst('ServerFailure: ', ''),
      );
      return false;
    }
  }

  void reset() {
    state = const MealAnalysisState();
  }
}
