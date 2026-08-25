import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

class MealTypeSelector extends StatelessWidget {
  final String selectedMealType;
  final ValueChanged<String> onSelected;

  const MealTypeSelector({
    super.key,
    required this.selectedMealType,
    required this.onSelected,
  });

  static const List<Map<String, dynamic>> _mealTypes = [
    {'id': 'breakfast', 'label': 'Breakfast', 'icon': Icons.wb_sunny_outlined},
    {'id': 'lunch', 'label': 'Lunch', 'icon': Icons.wb_twilight_outlined},
    {'id': 'dinner', 'label': 'Dinner', 'icon': Icons.nightlife_outlined},
    {'id': 'snack', 'label': 'Snack', 'icon': Icons.cookie_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meal Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _mealTypes.map((type) {
              final isSelected = selectedMealType.toLowerCase() == type['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: AnimatedScale(
                  scale: isSelected ? 1.04 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutCubic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutCubic,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context).cardColor,
                      borderRadius: AppRadius.pillBorder,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderLight,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: AppRadius.pillBorder,
                        onTap: () => onSelected(type['id'] as String),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                type['icon'] as IconData,
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.lightTextMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                type['label'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.lightTextPrimary,
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
            }).toList(),
          ),
        ),
      ],
    );
  }
}
