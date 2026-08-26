import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/theme/app_spacing.dart';
import 'package:bite_front_end/core/widgets/app_button.dart';
import 'package:bite_front_end/core/widgets/app_card.dart';
import 'package:bite_front_end/core/widgets/bite_fade_slide.dart';
import 'package:bite_front_end/core/widgets/bite_shimmer.dart';
import 'package:bite_front_end/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:bite_front_end/features/dashboard/presentation/widgets/calorie_progress_ring.dart';
import 'package:bite_front_end/features/dashboard/presentation/widgets/date_selector_bar.dart';
import 'package:bite_front_end/features/dashboard/presentation/widgets/historical_analytics_chart.dart';
import 'package:bite_front_end/features/dashboard/presentation/widgets/logged_meals_list.dart';
import 'package:bite_front_end/features/dashboard/presentation/widgets/macro_cards_grid.dart';
import 'package:bite_front_end/features/dashboard/presentation/widgets/top_micronutrients_card.dart';
import 'package:bite_front_end/features/meals/presentation/providers/meal_analysis_notifier.dart';
import 'package:bite_front_end/features/meals/presentation/providers/meal_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDashboardDateProvider);
    final dateStr = formatDateString(selectedDate);

    // Prime in-memory cache for the last 3 days (Today, Yesterday, 2 Days Ago) so date switching is instant
    final now = DateTime.now();
    final todayStr = formatDateString(now);
    final yesterdayStr = formatDateString(
      now.subtract(const Duration(days: 1)),
    );
    final twoDaysAgoStr = formatDateString(
      now.subtract(const Duration(days: 2)),
    );

    ref.listen(dailyDashboardProvider(todayStr), (prev, next) {});
    ref.listen(dailyDashboardProvider(yesterdayStr), (prev, next) {});
    ref.listen(dailyDashboardProvider(twoDaysAgoStr), (prev, next) {});

    // Automatically trigger state refresh on Dashboard whenever a new meal is logged
    ref.listen(mealAnalysisNotifierProvider, (prev, next) {
      if (next.status == MealAnalysisStatus.success) {
        ref.invalidate(dailyDashboardProvider(dateStr));
        ref.invalidate(dailyDashboardProvider(todayStr));
        ref.invalidate(historicalAnalyticsProvider(7));
        ref.invalidate(historicalAnalyticsProvider(30));
      }
    });

    final dashboardAsync = ref.watch(dailyDashboardProvider(dateStr));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.secondary,
          backgroundColor: Colors.white,
          onRefresh: () async {
            ref.invalidate(dailyDashboardProvider(dateStr));
            ref.invalidate(historicalAnalyticsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date Selection Capsule Bar (Today, Yesterday, no tomorrow)
                    const DateSelectorBar(),
                    const SizedBox(height: AppSpacing.lg),

                    dashboardAsync.when(
                      data: (dashboard) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BiteFadeSlide(
                              delay: Duration.zero,
                              duration: const Duration(milliseconds: 400),
                              child: CalorieProgressRing(
                                targetCalories: dashboard.targetCalories,
                                consumedCalories: dashboard.consumedCalories,
                                remainingCalories: dashboard.remainingCalories,
                                onLogMealPressed: () =>
                                    context.push('/meals/log'),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            BiteFadeSlide(
                              delay: const Duration(milliseconds: 100),
                              duration: const Duration(milliseconds: 400),
                              child: MacroCardsGrid(
                                currentProteinG: dashboard.protein.consumed,
                                targetProteinG: dashboard.protein.target,
                                currentCarbsG: dashboard.carbs.consumed,
                                targetCarbsG: dashboard.carbs.target,
                                currentFatG: dashboard.fat.consumed,
                                targetFatG: dashboard.fat.target,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            BiteFadeSlide(
                              delay: const Duration(milliseconds: 200),
                              duration: const Duration(milliseconds: 400),
                              child: LoggedMealsList(meals: dashboard.meals),
                            ),
                            if (dashboard.topMicronutrients.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.lg),
                              BiteFadeSlide(
                                delay: const Duration(milliseconds: 300),
                                duration: const Duration(milliseconds: 400),
                                child: TopMicronutrientsCard(
                                  topMicronutrients:
                                      dashboard.topMicronutrients,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            const BiteFadeSlide(
                              delay: Duration(milliseconds: 400),
                              duration: Duration(milliseconds: 400),
                              child: HistoricalAnalyticsChart(),
                            ),
                            const SizedBox(height: 90),
                          ],
                        );
                      },
                      loading: () => BiteShimmer(
                        child: Column(
                          children: const [
                            SizedBox(height: 20),
                            BiteShimmerBox(width: double.infinity, height: 260),
                            SizedBox(height: 16),
                            BiteShimmerBox(width: double.infinity, height: 100),
                            SizedBox(height: 16),
                            BiteShimmerBox(width: double.infinity, height: 150),
                          ],
                        ),
                      ),
                      error: (error, stackTrace) => AppCard(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 36,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const Text(
                              'Could Not Load Dashboard',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              error.toString().replaceAll(
                                'ServerException: ',
                                '',
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              label: 'Try Again',
                              onPressed: () {
                                ref.invalidate(dailyDashboardProvider(dateStr));
                              },
                              variant: AppButtonVariant.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
