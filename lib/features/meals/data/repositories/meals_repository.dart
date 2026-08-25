import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failure.dart';
import '../datasources/meals_remote_data_source.dart';
import '../models/meal_analysis_response_model.dart';
import '../models/meal_confirm_request_model.dart';
import '../models/meal_confirm_response_model.dart';

abstract class MealsRepository {
  Future<MealAnalysisResponseModel> analyzeMeal({
    XFile? file,
    String? imageUrl,
    String? userCaption,
    String? mealType,
  });

  Future<MealConfirmResponseModel> confirmMeal(MealConfirmRequestModel request);
}

class MealsRepositoryImpl implements MealsRepository {
  final MealsRemoteDataSource _remoteDataSource;

  MealsRepositoryImpl(this._remoteDataSource);

  @override
  Future<MealAnalysisResponseModel> analyzeMeal({
    XFile? file,
    String? imageUrl,
    String? userCaption,
    String? mealType,
  }) async {
    try {
      return await _remoteDataSource.analyzeMeal(
        file: file,
        imageUrl: imageUrl,
        userCaption: userCaption,
        mealType: mealType,
      );
    } on DioException catch (e) {
      final message =
          e.response?.data is Map && e.response?.data['detail'] != null
          ? e.response?.data['detail'].toString() ?? e.message
          : e.message ?? 'Failed to analyze meal image';
      throw ServerFailure(
        message ?? 'Server error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<MealConfirmResponseModel> confirmMeal(
    MealConfirmRequestModel request,
  ) async {
    try {
      return await _remoteDataSource.confirmMeal(request);
    } on DioException catch (e) {
      final message =
          e.response?.data is Map && e.response?.data['detail'] != null
          ? e.response?.data['detail'].toString() ?? e.message
          : e.message ?? 'Failed to confirm meal log';
      throw ServerFailure(
        message ?? 'Server error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
