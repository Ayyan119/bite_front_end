import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/meals_remote_data_source.dart';
import '../../data/repositories/meals_repository.dart';
import 'meal_analysis_notifier.dart';

final mealsRemoteDataSourceProvider = Provider<MealsRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return MealsRemoteDataSourceImpl(dio);
});

final mealsRepositoryProvider = Provider<MealsRepository>((ref) {
  final dataSource = ref.watch(mealsRemoteDataSourceProvider);
  return MealsRepositoryImpl(dataSource);
});

final mealAnalysisNotifierProvider =
    StateNotifierProvider<MealAnalysisNotifier, MealAnalysisState>((ref) {
      final repository = ref.watch(mealsRepositoryProvider);
      return MealAnalysisNotifier(repository, ref);
    });
