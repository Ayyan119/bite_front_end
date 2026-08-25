import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/dashboard_provider.dart';

class HistoricalAnalyticsChart extends ConsumerWidget {
  const HistoricalAnalyticsChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDays = ref.watch(historicalRangeDaysProvider);
    final historyAsync = ref.watch(historicalAnalyticsProvider(selectedDays));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.insights,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Macro Trends',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _RangeChip(
                    days: 7,
                    selectedDays: selectedDays,
                    onTap: () =>
                        ref.read(historicalRangeDaysProvider.notifier).state = 7,
                  ),
                  const SizedBox(width: 4),
                  _RangeChip(
                    days: 30,
                    selectedDays: selectedDays,
                    onTap: () =>
                        ref.read(historicalRangeDaysProvider.notifier).state = 30,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          historyAsync.when(
            data: (analytics) {
              if (analytics.history.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'No historical analytics logged yet.',
                      style: TextStyle(color: AppColors.lightTextSecondary),
                    ),
                  ),
                );
              }

              final maxCal = analytics.history
                  .map((e) => math.max(e.totalCalories, e.targetCalories))
                  .fold(1000.0, math.max);

              return Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: analytics.history.take(14).map((item) {
                        final barHeight = (item.totalCalories / maxCal * 120)
                            .clamp(10.0, 120.0);
                        final isOver = item.goalStatus.toLowerCase() == 'over';
                        final barColor = isOver
                            ? AppColors.secondary
                            : AppColors.primary;

                        return Expanded(
                          child: Tooltip(
                            message:
                                '${item.date}: ${item.totalCalories.toInt()} kcal',
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      color: barColor,
                                      borderRadius: BorderRadius.vertical(
                                        top: AppRadius.smBorder.topLeft,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.date.split('-').last,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.lightTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatusLegend(
                        label: 'Within Goal',
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSpacing.lg),
                      _StatusLegend(
                        label: 'Over Target',
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Could not load trends: $err',
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final int days;
  final int selectedDays;
  final VoidCallback onTap;

  const _RangeChip({
    required this.days,
    required this.selectedDays,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = days == selectedDays;

    return ChoiceChip(
      label: Text(
        '${days}D',
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.lightTextSecondary,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.inputFill,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.pillBorder,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.inputBorder,
        ),
      ),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusLegend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
