import 'package:flutter_test/flutter_test.dart';
import 'package:bite_front_end/features/auth/data/models/auth_response_model.dart';
import 'package:bite_front_end/features/auth/data/models/login_request_model.dart';
import 'package:bite_front_end/features/auth/data/models/register_request_model.dart';
import 'package:bite_front_end/features/auth/data/models/dev_token_request_model.dart';
import 'package:bite_front_end/features/profile/data/models/user_profile_response_model.dart';
import 'package:bite_front_end/features/dashboard/data/models/daily_dashboard_response_model.dart';
import 'package:bite_front_end/features/dashboard/data/models/historical_analytics_response_model.dart';
import 'package:bite_front_end/features/meals/data/models/meal_analysis_response_model.dart';
import 'package:bite_front_end/features/meals/data/models/meal_confirm_response_model.dart';
import 'package:bite_front_end/features/chat/data/models/chat_session_response_model.dart';
import 'package:bite_front_end/features/chat/data/models/chat_message_response_model.dart';

void main() {
  group('Auth DTO Models', () {
    test('LoginRequestModel serializes correctly', () {
      const model = LoginRequestModel(
        email: 'user@example.com',
        password: 'user_password',
      );
      final json = model.toJson();
      expect(json['email'], equals('user@example.com'));
      expect(json['password'], equals('user_password'));
    });

    test('AuthResponseModel deserializes sample API response correctly', () {
      final json = {
        'access_token': 'eyJhbGciOiJIUzI1NiIs...',
        'token_type': 'bearer',
        'expires_in': 86400,
        'user_id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'email': 'user@example.com',
        'display_name': 'User Name',
        'age': 28,
        'height_cm': 178.0,
        'weight_kg': 75.0,
        'gender': 'male',
        'bmr': 1720.0,
        'tdee': 2666.0,
        'target_calories': 2400.0,
      };

      final model = AuthResponseModel.fromJson(json);
      expect(model.accessToken, equals('eyJhbGciOiJIUzI1NiIs...'));
      expect(model.email, equals('user@example.com'));
      expect(model.targetCalories, equals(2400.0));
      expect(model.tdee, equals(2666.0));
    });

    test('RegisterRequestModel serializes and deserializes', () {
      const model = RegisterRequestModel(
        email: 'newuser@example.com',
        password: 'secret_password',
        displayName: 'New User',
        age: 25,
        heightCm: 175.0,
        weightKg: 70.0,
        gender: 'male',
        activityLevel: 'moderate',
        primaryGoal: 'muscle_gain',
      );
      final json = model.toJson();
      final decoded = RegisterRequestModel.fromJson(json);
      expect(decoded.displayName, equals('New User'));
      expect(decoded.primaryGoal, equals('muscle_gain'));
    });

    test('DevTokenRequestModel serializes correctly', () {
      const model = DevTokenRequestModel(email: 'alex.morgan@bite.app');
      final json = model.toJson();
      expect(json['email'], equals('alex.morgan@bite.app'));
      expect(json['user_id'], isNull);
    });
  });

  group('Profile DTO Models', () {
    test('UserProfileResponseModel deserializes sample payload', () {
      final json = {
        'id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'display_name': 'Alex Morgan',
        'height_cm': 178.0,
        'weight_kg': 75.0,
        'age': 28,
        'gender': 'male',
        'activity_level': 'moderate',
        'primary_goal': 'muscle_gain',
        'bmr': 1720.0,
        'tdee': 2666.0,
        'target_calories': 2400.0,
        'target_protein_g': 180.0,
        'target_carbs_g': 250.0,
        'target_fat_g': 70.0,
        'target_micronutrients': {},
      };

      final model = UserProfileResponseModel.fromJson(json);
      expect(model.displayName, equals('Alex Morgan'));
      expect(model.targetProteinG, equals(180.0));
    });
  });

  group('Dashboard DTO Models', () {
    test('DailyDashboardResponseModel deserializes daily summary payload', () {
      final json = {
        'date': '2026-08-25',
        'target_calories': 2400.0,
        'consumed_calories': 1872.0,
        'remaining_calories': 528.0,
        'protein': {'target': 180.0, 'consumed': 75.0, 'remaining': 105.0},
        'carbs': {'target': 250.0, 'consumed': 243.6, 'remaining': 6.4},
        'fat': {'target': 70.0, 'consumed': 37.5, 'remaining': 32.5},
        'meals': [
          {
            'meal_id': 'c1f7b8e0-1234-4567-89ab-cdef01234567',
            'meal_type': 'snack',
            'user_caption': 'Banana Snack',
            'image_url': 'https://example.com/banana.jpg',
            'calories': 1872.0,
            'protein_g': 75.0,
            'carbs_g': 243.6,
            'fat_g': 37.5,
            'logged_at': '2026-08-25 15:30:00+00',
          },
        ],
        'top_micronutrients': {'Fiber, total dietary (g)': 37.2},
      };

      final model = DailyDashboardResponseModel.fromJson(json);
      expect(model.date, equals('2026-08-25'));
      expect(model.meals.length, equals(1));
      expect(model.meals.first.mealType, equals('snack'));
      expect(model.topMicronutrients['Fiber, total dietary (g)'], equals(37.2));
    });

    test('HistoricalAnalyticsResponseModel deserializes history payload', () {
      final json = {
        'user_id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'total_days_logged': 1,
        'history': [
          {
            'date': '2026-08-25',
            'meal_count': 1,
            'total_calories': 1872.0,
            'target_calories': 2400.0,
            'total_protein_g': 75.0,
            'target_protein_g': 180.0,
            'total_carbs_g': 243.6,
            'target_carbs_g': 250.0,
            'total_fat_g': 37.5,
            'target_fat_g': 70.0,
            'goal_status': 'under',
          },
        ],
      };

      final model = HistoricalAnalyticsResponseModel.fromJson(json);
      expect(model.totalDaysLogged, equals(1));
      expect(model.history.first.goalStatus, equals('under'));
    });
  });

  group('Meals DTO Models', () {
    test('MealAnalysisResponseModel deserializes vision output', () {
      final json = {
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
      };

      final model = MealAnalysisResponseModel.fromJson(json);
      expect(model.mealType, equals('breakfast'));
      expect(model.detectedItems.length, equals(1));
      expect(model.detectedItems.first.foodName, equals('Banana'));
    });

    test('MealConfirmResponseModel deserializes confirmation payload', () {
      final json = {
        'meal_id': 'c1f7b8e0-1234-4567-89ab-cdef01234567',
        'user_id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'logged_at': '2026-08-25 10:30:00+00',
        'meal_type': 'breakfast',
        'total_calories': 210.04,
        'total_protein_g': 2.57,
        'total_carbs_g': 53.81,
        'total_fat_g': 0.78,
        'item_count': 1,
      };

      final model = MealConfirmResponseModel.fromJson(json);
      expect(model.mealId, equals('c1f7b8e0-1234-4567-89ab-cdef01234567'));
      expect(model.itemCount, equals(1));
    });
  });

  group('Chat DTO Models', () {
    test('ChatSessionResponseModel deserializes session info', () {
      final json = {
        'id': 'c1f7b8e0-1234-4567-89ab-cdef01234567',
        'user_id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'title': 'Lunch Logging: Chicken Biryani',
        'created_at': '2026-08-25 10:00:00+00',
        'updated_at': '2026-08-25 10:05:00+00',
        'message_count': 4,
      };

      final model = ChatSessionResponseModel.fromJson(json);
      expect(model.title, equals('Lunch Logging: Chicken Biryani'));
      expect(model.messageCount, equals(4));
    });

    test('ChatMessageResponseModel deserializes message item', () {
      final json = {
        'id': 'm1f7b8e0-1234-4567-89ab-cdef01234567',
        'session_id': 'c1f7b8e0-1234-4567-89ab-cdef01234567',
        'role': 'user',
        'content': 'I ate 300g chicken biryani for lunch',
        'created_at': '2026-08-25 10:00:00+00',
      };

      final model = ChatMessageResponseModel.fromJson(json);
      expect(model.role, equals('user'));
      expect(model.content, contains('chicken biryani'));
    });
  });
}
