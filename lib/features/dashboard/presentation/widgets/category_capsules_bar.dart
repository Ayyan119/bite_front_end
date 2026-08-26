import 'package:flutter/material.dart';
import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/theme/app_radius.dart';

class CategoryCapsulesBar extends StatefulWidget {
  final ValueChanged<int>? onCategorySelected;

  const CategoryCapsulesBar({super.key, this.onCategorySelected});

  @override
  State<CategoryCapsulesBar> createState() => _CategoryCapsulesBarState();
}

class _CategoryCapsulesBarState extends State<CategoryCapsulesBar> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _categories = const [
    {'isFlame': true},
    {'isFlame': false, 'label': 'Calories'},
    {'isFlame': false, 'label': 'Protein'},
    {'isFlame': false, 'label': 'Carbs'},
    {'isFlame': false, 'label': 'Fat'},
    {'isFlame': false, 'label': 'Logged Meals'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = _categories[index];
          final isSelected = _selectedIndex == index;
          final isFlame = item['isFlame'] == true;

          // Theme dynamic colors
          Color activeBg;
          Color inactiveBg;
          Color activeText;
          Color inactiveText;
          Color borderColor;

          if (isDark) {
            activeBg = isFlame
                ? AppColors.secondary
                : AppColors.capsuleActiveWhite;
            inactiveBg = const Color(0xFF161A26);
            activeText = isFlame
                ? Colors.white
                : AppColors.capsuleActiveDarkText;
            inactiveText = AppColors.darkTextSecondary;
            borderColor = isSelected
                ? (isFlame ? AppColors.secondary : Colors.white)
                : const Color(0x26FFFFFF);
          } else {
            activeBg = isFlame ? AppColors.secondary : const Color(0xFF1E2025);
            inactiveBg = Colors.white;
            activeText = Colors.white;
            inactiveText = AppColors.lightTextPrimary;
            borderColor = isSelected
                ? (isFlame ? AppColors.secondary : const Color(0xFF1E2025))
                : const Color(0xFFE2E8F0);
          }

          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = index);
              widget.onCategorySelected?.call(index);
            },
            child: AnimatedScale(
              scale: isSelected ? 1.04 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isFlame ? 14 : 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? activeBg : inactiveBg,
                  borderRadius: AppRadius.pillBorder,
                  border: Border.all(color: borderColor, width: 1.0),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeBg.withValues(
                              alpha: isDark ? 0.3 : 0.15,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                        ],
                ),
                child: isFlame
                    ? Icon(
                        Icons.local_fire_department_rounded,
                        size: 20,
                        color: isSelected ? Colors.white : AppColors.secondary,
                      )
                    : Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? activeText : inactiveText,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
