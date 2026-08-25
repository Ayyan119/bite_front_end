import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/dashboard_provider.dart';

class DateSelectorBar extends ConsumerWidget {
  const DateSelectorBar({super.key});

  void _changeDate(WidgetRef ref, int daysOffset) {
    final currentDate = ref.read(selectedDashboardDateProvider);
    ref.read(selectedDashboardDateProvider.notifier).state = currentDate.add(
      Duration(days: daysOffset),
    );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final currentDate = ref.read(selectedDashboardDateProvider);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.lightSurface,
              onSurface: AppColors.lightTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      ref.read(selectedDashboardDateProvider.notifier).state = pickedDate;
    }
  }

  String _formatDisplayDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return 'Today, ${DateFormat('MMM d').format(date)}';
    } else if (target == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('MMM d').format(date)}';
    } else if (target == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${DateFormat('MMM d').format(date)}';
    }
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDashboardDateProvider);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: AppRadius.pillBorder,
        border: Border.all(color: AppColors.inputBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.lightTextPrimary,
              size: 24,
            ),
            onPressed: () => _changeDate(ref, -1),
            tooltip: 'Previous Day',
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context, ref),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _formatDisplayDate(selectedDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.lightTextPrimary,
              size: 24,
            ),
            onPressed: () => _changeDate(ref, 1),
            tooltip: 'Next Day',
          ),
        ],
      ),
    );
  }
}
