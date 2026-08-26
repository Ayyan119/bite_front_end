import 'package:bite_front_end/features/dashboard/data/models/daily_dashboard_response_model.dart';
import 'package:bite_front_end/features/dashboard/data/models/historical_analytics_response_model.dart';
import 'package:bite_front_end/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:bite_front_end/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DailyDashboardResponseModel> getDailyDashboard(String dateStr) async {
    return DailyDashboardResponseModel(
      date: dateStr,
      targetCalories: 2400.0,
      consumedCalories: 1872.0,
      remainingCalories: 528.0,
      protein: const MacroProgressModel(
        target: 180,
        consumed: 75,
        remaining: 105,
      ),
      carbs: const MacroProgressModel(
        target: 250,
        consumed: 243.6,
        remaining: 6.4,
      ),
      fat: const MacroProgressModel(
        target: 70,
        consumed: 37.5,
        remaining: 32.5,
      ),
      meals: const [
        LoggedMealSummaryModel(
          mealId: 'm1',
          mealType: 'snack',
          userCaption: 'Banana Snack',
          calories: 210.0,
          proteinG: 2.5,
          carbsG: 53.8,
          fatG: 0.8,
          loggedAt: '2026-08-25 15:30:00+00',
        ),
      ],
      topMicronutrients: const {'Fiber': 37.2},
    );
  }

  @override
  Future<HistoricalAnalyticsResponseModel> getHistoricalAnalytics(
    int days,
  ) async {
    return const HistoricalAnalyticsResponseModel(
      userId: 'user_1',
      totalDaysLogged: 1,
      history: [
        DailyHistoryItemModel(
          date: '2026-08-25',
          mealCount: 1,
          totalCalories: 1872.0,
          targetCalories: 2400.0,
          totalProteinG: 75.0,
          targetProteinG: 180.0,
          totalCarbsG: 243.6,
          targetCarbsG: 250.0,
          totalFatG: 37.5,
          targetFatG: 70.0,
          goalStatus: 'under',
        ),
      ],
    );
  }
}

void main() {
  testWidgets(
    'DashboardScreen renders calorie ring, macro grid, and logged meals',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardRepositoryProvider.overrideWithValue(
              MockDashboardRepository(),
            ),
          ],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('1872'), findsOneWidget);
      expect(find.text('of 2400 kcal'), findsOneWidget);
      expect(find.text('528 kcal remaining'), findsOneWidget);
      expect(find.text('Protein'), findsWidgets);
      expect(find.text('Carbs'), findsWidgets);
      expect(find.text('Fat'), findsWidgets);
      expect(find.text('Banana Snack'), findsOneWidget);
      expect(find.text('Macro Trends'), findsOneWidget);
    },
  );
}
