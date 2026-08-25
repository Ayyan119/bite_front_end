import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/calorie_progress_ring.dart';
import '../widgets/date_selector_bar.dart';
import '../widgets/historical_analytics_chart.dart';
import '../widgets/logged_meals_list.dart';
import '../widgets/macro_card_grid.dart';
import '../widgets/top_micronutrients_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDashboardDateProvider);
    final dateStr = formatDateString(selectedDate);
    final dashboardAsync = ref.watch(dailyDashboardProvider(dateStr));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
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
                    const DateSelectorBar(),
                    const SizedBox(height: AppSpacing.lg),
                    dashboardAsync.when(
                      data: (dashboard) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CalorieProgressRing(
                              targetCalories: dashboard.targetCalories,
                              consumedCalories: dashboard.consumedCalories,
                              remainingCalories: dashboard.remainingCalories,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            MacroCardGrid(
                              protein: dashboard.protein,
                              carbs: dashboard.carbs,
                              fat: dashboard.fat,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            LoggedMealsList(meals: dashboard.meals),
                            if (dashboard.topMicronutrients.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.lg),
                              TopMicronutrientsCard(
                                topMicronutrients: dashboard.topMicronutrients,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            const HistoricalAnalyticsChart(),
                          ],
                        );
                      },
                      loading: () => const Column(
                        children: [
                          SizedBox(height: 60),
                          Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading your daily macro dashboard...',
                            style: TextStyle(
                              color: AppColors.lightTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 60),
                        ],
                      ),
                      error: (error, stackTrace) => AppCard(
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
