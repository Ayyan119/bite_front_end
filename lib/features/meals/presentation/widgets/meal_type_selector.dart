import 'package:flutter/material.dart';
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
    {
      'id': 'breakfast',
      'label': 'Breakfast',
      'icon': Icons.wb_sunny_rounded,
      'badgeBg': Color(0xFFFFF7ED),
      'iconColor': Color(0xFFF59E0B),
    },
    {
      'id': 'lunch',
      'label': 'Lunch',
      'icon': Icons.restaurant_rounded,
      'badgeBg': Color(0xFFECFDF5),
      'iconColor': Color(0xFF10B981),
    },
    {
      'id': 'dinner',
      'label': 'Dinner',
      'icon': Icons.dinner_dining_rounded,
      'badgeBg': Color(0xFFFEF2F2),
      'iconColor': Color(0xFFEF4444),
    },
    {
      'id': 'snack',
      'label': 'Snack',
      'icon': Icons.cookie_rounded,
      'badgeBg': Color(0xFFF3E8FF),
      'iconColor': Color(0xFFA855F7),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MEAL CATEGORY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: _mealTypes.map((type) {
              final isSelected = selectedMealType.toLowerCase() == type['id'];
              final badgeBg = type['badgeBg'] as Color;
              final iconColor = type['iconColor'] as Color;

              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: AnimatedScale(
                  scale: isSelected ? 1.04 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutCubic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOutCubic,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : Colors.white,
                      borderRadius: AppRadius.pillBorder,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF0F172A,
                                ).withValues(alpha: 0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: AppRadius.pillBorder,
                        onTap: () => onSelected(type['id'] as String),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.15)
                                      : badgeBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  type['icon'] as IconData,
                                  size: 14,
                                  color: isSelected ? Colors.white : iconColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                type['label'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
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
