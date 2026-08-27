import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/theme/app_radius.dart';
import 'package:bite_front_end/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DateSelectorBar extends ConsumerWidget {
  const DateSelectorBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDashboardDateProvider);

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final currentDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    final isToday = currentDate.isAtSameMomentAs(todayDate);
    final isYesterday = currentDate.isAtSameMomentAs(yesterdayDate);

    String formattedDate;
    if (isToday) {
      formattedDate = 'Today, ${DateFormat('MMM d').format(selectedDate)}';
    } else if (isYesterday) {
      formattedDate = 'Yesterday, ${DateFormat('MMM d').format(selectedDate)}';
    } else {
      formattedDate = DateFormat('EEEE, MMM d').format(selectedDate);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.pillBorder,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Day Chevron
          IconButton(
            onPressed: () {
              ref.read(selectedDashboardDateProvider.notifier).state =
                  currentDate.subtract(const Duration(days: 1));
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                size: 20,
                color: AppColors.lightTextPrimary,
              ),
            ),
            tooltip: 'Previous Day',
          ),

          // Date Badge & Picker Trigger
          Flexible(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: currentDate.isAfter(todayDate)
                      ? todayDate
                      : currentDate,
                  firstDate: DateTime(2020),
                  lastDate: todayDate, // Cannot select future dates!
                );
                if (picked != null) {
                  ref.read(selectedDashboardDateProvider.notifier).state =
                      DateTime(picked.year, picked.month, picked.day);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary : const Color(0xFF1E2025),
                  borderRadius: AppRadius.pillBorder,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isToday
                                  ? AppColors.primary
                                  : const Color(0xFF1E2025))
                              .withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Next Day Chevron (Disabled when on Today, preventing future date navigation!)
          IconButton(
            onPressed: isToday
                ? null
                : () {
                    final nextDate = currentDate.add(const Duration(days: 1));
                    if (!nextDate.isAfter(todayDate)) {
                      ref.read(selectedDashboardDateProvider.notifier).state =
                          nextDate;
                    }
                  },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isToday
                    ? const Color(0xFFF8FAFC)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isToday
                    ? const Color(0xFFCBD5E1)
                    : AppColors.lightTextPrimary,
              ),
            ),
            tooltip: 'Next Day',
          ),
        ],
      ),
    );
  }
}
