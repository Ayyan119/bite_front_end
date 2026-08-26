import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/historical_analytics_response_model.dart';
import '../providers/dashboard_provider.dart';

class HistoricalAnalyticsChart extends ConsumerStatefulWidget {
  const HistoricalAnalyticsChart({super.key});

  @override
  ConsumerState<HistoricalAnalyticsChart> createState() =>
      _HistoricalAnalyticsChartState();
}

class _HistoricalAnalyticsChartState
    extends ConsumerState<HistoricalAnalyticsChart> {
  DailyHistoryItemModel? _selectedItem;

  @override
  Widget build(BuildContext context) {
    final selectedDays = ref.watch(historicalRangeDaysProvider);
    final selectedMetric = ref.watch(selectedTrendMetricProvider);
    final historyAsync = ref.watch(historicalAnalyticsProvider(selectedDays));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      backgroundColor: AppColors.cardTrend,
      borderSide: const BorderSide(
        color: AppColors.cardTrendBorder,
        width: 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & 7D / 30D Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.grid_view_rounded,
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
              _RangeSegmentSwitcher(
                selectedDays: selectedDays,
                onDaysSelected: (days) {
                  ref.read(historicalRangeDaysProvider.notifier).state = days;
                  setState(() => _selectedItem = null);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 4 Option Chips (Calories selected by default)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TrendMetric.values.map((metric) {
                return _MetricOptionChip(
                  metric: metric,
                  isSelected: metric == selectedMetric,
                  onTap: () {
                    ref.read(selectedTrendMetricProvider.notifier).state =
                        metric;
                    setState(() => _selectedItem = null);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Contribution Heatmap Board
          historyAsync.when(
            data: (analytics) {
              final paddedItems = _generatePaddedDaysList(
                analytics.history,
                selectedDays,
              );

              final completedCount = paddedItems.where((item) {
                final ratio = _getMetricRatio(item, selectedMetric);
                return item.mealCount > 0 && ratio >= 0.90 && ratio <= 1.15;
              }).length;

              final loggedDaysCount = paddedItems
                  .where((item) => item.mealCount > 0)
                  .length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Board Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: AppRadius.lgBorder,
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.cardTrendBorder,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heatmap Header Subtitle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '$selectedDays Days Activity (${_getMetricName(selectedMetric)})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: AppRadius.pillBorder,
                              ),
                              child: Text(
                                '$completedCount / $selectedDays target met',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Grid of Heatmap Boxes (7 boxes for 7D, 30 boxes for 30D)
                        if (selectedDays == 7)
                          _buildSevenDaysRow(
                            paddedItems,
                            selectedMetric,
                            isDark,
                          )
                        else
                          _buildThirtyDaysGrid(
                            paddedItems,
                            selectedMetric,
                            isDark,
                          ),

                        const SizedBox(height: AppSpacing.md),

                        // Legend Row: Less -> Empty -> Dull -> Medium -> Bright -> Red -> More
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Logged: $loggedDaysCount/$selectedDays days',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextMuted,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Empty',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextMuted,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                _LegendBox(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9),
                                  borderColor: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1),
                                  tooltip: 'Empty / No meal logged',
                                ),
                                const SizedBox(width: 4),
                                _LegendBox(
                                  color: _getMetricBaseColor(
                                    selectedMetric,
                                  ).withValues(alpha: 0.35),
                                  tooltip: 'Low intake (<60%)',
                                ),
                                const SizedBox(width: 4),
                                _LegendBox(
                                  color: _getMetricBaseColor(
                                    selectedMetric,
                                  ).withValues(alpha: 0.65),
                                  tooltip: 'Moderate intake (60-90%)',
                                ),
                                const SizedBox(width: 4),
                                _LegendBox(
                                  color: _getMetricBaseColor(selectedMetric),
                                  tooltip: 'Bright Target Complete (90-115%)',
                                ),
                                const SizedBox(width: 4),
                                const _LegendBox(
                                  color: Color(0xFFEF4444),
                                  tooltip: 'Red Overflow Target (>115%)',
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Overflow',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tapped Day Detail Popup Box
                  if (_selectedItem != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildSelectedItemCard(_selectedItem!, selectedMetric),
                  ],
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

  // 7D Layout: Exactly 7 boxes in a wide responsive row with Day labels above each
  Widget _buildSevenDaysRow(
    List<DailyHistoryItemModel> items,
    TrendMetric metric,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) {
        final isSelected = _selectedItem?.date == item.date;
        final status = _getMetricStatus(item, metric);
        final color = _getHeatmapColor(status, metric, isDark);
        final borderColor = _getHeatmapBorderColor(
          status,
          metric,
          isDark,
          isSelected,
        );
        final dayLabel = _formatDayLabel(item.date);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedItem = isSelected ? null : item;
                });
              },
              child: Column(
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextMuted),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 34,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: borderColor,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: item.mealCount == 0
                          ? Icon(
                              Icons.remove_rounded,
                              size: 14,
                              color: isDark
                                  ? AppColors.darkTextSecondary.withValues(
                                      alpha: 0.4,
                                    )
                                  : AppColors.lightTextMuted.withValues(
                                      alpha: 0.4,
                                    ),
                            )
                          : (status == _ContributionStatus.complete
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 30D Layout: Exactly 30 boxes grid (5 columns x 6 rows)
  Widget _buildThirtyDaysGrid(
    List<DailyHistoryItemModel> items,
    TrendMetric metric,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = _selectedItem?.date == item.date;
            final status = _getMetricStatus(item, metric);
            final color = _getHeatmapColor(status, metric, isDark);
            final borderColor = _getHeatmapBorderColor(
              status,
              metric,
              isDark,
              isSelected,
            );

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedItem = isSelected ? null : item;
                });
              },
              child: Tooltip(
                message: _buildShortDateTooltip(item.date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: borderColor,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: item.mealCount == 0
                      ? Center(
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSelectedItemCard(
    DailyHistoryItemModel item,
    TrendMetric metric,
  ) {
    final ratio = _getMetricRatio(item, metric);
    final consumed = _getMetricConsumed(item, metric);
    final target = _getMetricTarget(item, metric);
    final unit = metric == TrendMetric.calories ? 'kcal' : 'g';
    final formattedDate = _formatDate(item.date);

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (item.mealCount == 0 || consumed == 0) {
      statusText = 'No Meals Logged';
      statusColor = AppColors.lightTextMuted;
      statusIcon = Icons.remove_circle_outline_rounded;
    } else if (ratio > 1.15) {
      statusText = 'Overflow Target';
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.warning_amber_rounded;
    } else if (ratio >= 0.90) {
      statusText = 'Target Complete!';
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_rounded;
    } else {
      statusText = 'Incomplete Goal';
      statusColor = AppColors.warning;
      statusIcon = Icons.hourglass_bottom_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  item.mealCount == 0
                      ? 'No food items logged for this date'
                      : '${consumed.toInt()} / ${target.toInt()} $unit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: AppRadius.pillBorder,
            ),
            child: Text(
              statusText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Generates padded days list matching daysCount (7 or 30 consecutive calendar days ending today)
  List<DailyHistoryItemModel> _generatePaddedDaysList(
    List<DailyHistoryItemModel> loggedItems,
    int daysCount,
  ) {
    final Map<String, DailyHistoryItemModel> mapByDate = {
      for (var item in loggedItems) item.date: item,
    };

    final now = DateTime.now();
    final List<DailyHistoryItemModel> padded = [];

    for (int i = daysCount - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      if (mapByDate.containsKey(dateStr)) {
        padded.add(mapByDate[dateStr]!);
      } else {
        padded.add(
          DailyHistoryItemModel(
            date: dateStr,
            mealCount: 0,
            totalCalories: 0.0,
            targetCalories: 2000.0,
            totalProteinG: 0.0,
            targetProteinG: 150.0,
            totalCarbsG: 0.0,
            targetCarbsG: 200.0,
            totalFatG: 0.0,
            targetFatG: 70.0,
            goalStatus: 'under',
          ),
        );
      }
    }

    return padded;
  }

  double _getMetricRatio(DailyHistoryItemModel item, TrendMetric metric) {
    final target = _getMetricTarget(item, metric);
    final consumed = _getMetricConsumed(item, metric);
    if (target <= 0) return 0.0;
    return consumed / target;
  }

  double _getMetricConsumed(DailyHistoryItemModel item, TrendMetric metric) {
    switch (metric) {
      case TrendMetric.calories:
        return item.totalCalories;
      case TrendMetric.protein:
        return item.totalProteinG;
      case TrendMetric.carbs:
        return item.totalCarbsG;
      case TrendMetric.fat:
        return item.totalFatG;
    }
  }

  double _getMetricTarget(DailyHistoryItemModel item, TrendMetric metric) {
    switch (metric) {
      case TrendMetric.calories:
        return item.targetCalories;
      case TrendMetric.protein:
        return item.targetProteinG;
      case TrendMetric.carbs:
        return item.targetCarbsG;
      case TrendMetric.fat:
        return item.targetFatG;
    }
  }

  _ContributionStatus _getMetricStatus(
    DailyHistoryItemModel item,
    TrendMetric metric,
  ) {
    final consumed = _getMetricConsumed(item, metric);
    final ratio = _getMetricRatio(item, metric);

    if (item.mealCount == 0 || consumed == 0) return _ContributionStatus.empty;
    if (ratio > 1.15) return _ContributionStatus.overflow;
    if (ratio >= 0.90) return _ContributionStatus.complete;
    if (ratio >= 0.50) return _ContributionStatus.moderate;
    return _ContributionStatus.low;
  }

  Color _getHeatmapColor(
    _ContributionStatus status,
    TrendMetric metric,
    bool isDark,
  ) {
    final baseColor = _getMetricBaseColor(metric);

    switch (status) {
      case _ContributionStatus.empty:
        return isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
      case _ContributionStatus.low:
        return baseColor.withValues(alpha: 0.35);
      case _ContributionStatus.moderate:
        return baseColor.withValues(alpha: 0.65);
      case _ContributionStatus.complete:
        return baseColor;
      case _ContributionStatus.overflow:
        return const Color(0xFFEF4444);
    }
  }

  Color _getHeatmapBorderColor(
    _ContributionStatus status,
    TrendMetric metric,
    bool isDark,
    bool isSelected,
  ) {
    if (isSelected) return Colors.black87;

    switch (status) {
      case _ContributionStatus.empty:
        return isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
      case _ContributionStatus.overflow:
        return const Color(0xFFDC2626);
      case _ContributionStatus.complete:
      case _ContributionStatus.moderate:
      case _ContributionStatus.low:
        return _getMetricBaseColor(metric).withValues(alpha: 0.5);
    }
  }

  Color _getMetricBaseColor(TrendMetric metric) {
    switch (metric) {
      case TrendMetric.calories:
        return const Color(0xFF10B981); // Emerald Green
      case TrendMetric.protein:
        return AppColors.protein; // Vibrant Blue
      case TrendMetric.carbs:
        return AppColors.carbs; // Warm Amber
      case TrendMetric.fat:
        return AppColors.fat; // Mint Green
    }
  }

  String _getMetricName(TrendMetric metric) {
    switch (metric) {
      case TrendMetric.calories:
        return 'Calories';
      case TrendMetric.protein:
        return 'Protein';
      case TrendMetric.carbs:
        return 'Carbs';
      case TrendMetric.fat:
        return 'Fat';
    }
  }

  String _buildShortDateTooltip(String rawDate) {
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('d-MMM').format(parsed); // e.g., "30-Jul", "26-Aug"
    } catch (_) {
      return rawDate;
    }
  }

  String _formatDate(String rawDate) {
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('EEE, MMM d').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  String _formatDayLabel(String rawDate) {
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('E').format(parsed)[0]; // M, T, W, T, F, S, S
    } catch (_) {
      return '';
    }
  }
}

enum _ContributionStatus { empty, low, moderate, complete, overflow }

class _MetricOptionChip extends StatelessWidget {
  final TrendMetric metric;
  final bool isSelected;
  final VoidCallback onTap;

  const _MetricOptionChip({
    required this.metric,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String label;
    final IconData icon;
    final Color color;

    switch (metric) {
      case TrendMetric.calories:
        label = 'Calories';
        icon = Icons.local_fire_department_rounded;
        color = const Color(0xFF10B981);
        break;
      case TrendMetric.protein:
        label = 'Protein';
        icon = Icons.fitness_center_rounded;
        color = AppColors.protein;
        break;
      case TrendMetric.carbs:
        label = 'Carbs';
        icon = Icons.grain_rounded;
        color = AppColors.carbs;
        break;
      case TrendMetric.fat:
        label = 'Fat';
        icon = Icons.water_drop_rounded;
        color = AppColors.fat;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillBorder,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.inputBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.lightTextMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RangeSegmentSwitcher extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onDaysSelected;

  const _RangeSegmentSwitcher({
    required this.selectedDays,
    required this.onDaysSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
        borderRadius: AppRadius.pillBorder,
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [7, 30].map((days) {
          final isSelected = days == selectedDays;
          return GestureDetector(
            onTap: () => onDaysSelected(days),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.darkCard : Colors.white)
                    : Colors.transparent,
                borderRadius: AppRadius.pillBorder,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                '${days}D',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextMuted),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LegendBox extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final String tooltip;

  const _LegendBox({
    required this.color,
    this.borderColor,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
      ),
    );
  }
}
