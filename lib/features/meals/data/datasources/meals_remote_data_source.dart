import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/constants/api_constants.dart';
import '../models/meal_analysis_response_model.dart';
import '../models/meal_confirm_request_model.dart';
import '../models/meal_confirm_response_model.dart';

abstract class MealsRemoteDataSource {
  Future<MealAnalysisResponseModel> analyzeMeal({
    XFile? file,
    String? imageUrl,
    String? userCaption,
    String? mealType,
  });

  Future<MealConfirmResponseModel> confirmMeal(MealConfirmRequestModel request);
}

class MealsRemoteDataSourceImpl implements MealsRemoteDataSource {
  final Dio _dio;

  MealsRemoteDataSourceImpl(this._dio);

  @override
  Future<MealAnalysisResponseModel> analyzeMeal({
    XFile? file,
    String? imageUrl,
    String? userCaption,
    String? mealType,
  }) async {
    if (file != null) {
      final Map<String, dynamic> formMap = {};
      if (userCaption != null && userCaption.trim().isNotEmpty) {
        formMap['user_caption'] = userCaption.trim();
      }
      if (mealType != null && mealType.isNotEmpty) {
        formMap['meal_type'] = mealType;
      }

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        formMap['file'] = MultipartFile.fromBytes(
          bytes,
          filename: file.name.isNotEmpty ? file.name : 'meal_image.jpg',
        );
      } else {
        formMap['file'] = await MultipartFile.fromFile(
          file.path,
          filename: file.name.isNotEmpty ? file.name : 'meal_image.jpg',
        );
      }

      final formData = FormData.fromMap(formMap);
      final response = await _dio.post(
        ApiConstants.mealsAnalyze,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return MealAnalysisResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } else {
      final Map<String, dynamic> body = {};
      if (imageUrl != null && imageUrl.isNotEmpty) {
        body['image_url'] = imageUrl;
      }
      if (userCaption != null && userCaption.trim().isNotEmpty) {
        body['user_caption'] = userCaption.trim();
      }
      if (mealType != null && mealType.isNotEmpty) {
        body['meal_type'] = mealType;
      }

      final response = await _dio.post(ApiConstants.mealsAnalyze, data: body);
      return MealAnalysisResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
  }

  @override
  Future<MealConfirmResponseModel> confirmMeal(
    MealConfirmRequestModel request,
  ) async {
    final response = await _dio.post(
      ApiConstants.mealsConfirm,
      data: request.toJson(),
    );
    return MealConfirmResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
