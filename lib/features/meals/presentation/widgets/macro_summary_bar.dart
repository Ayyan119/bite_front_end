import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

class MacroSummaryBar extends StatelessWidget {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const MacroSummaryBar({
    super.key,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(
            label: 'Calories',
            value: calories,
            unit: 'kcal',
            color: AppColors.calories,
            icon: Icons.local_fire_department_rounded,
          ),
          _buildDivider(),
          _buildItem(
            label: 'Protein',
            value: proteinG,
            unit: 'g',
            color: AppColors.protein,
            icon: Icons.fitness_center_rounded,
          ),
          _buildDivider(),
          _buildItem(
            label: 'Carbs',
            value: carbsG,
            unit: 'g',
            color: AppColors.carbs,
            icon: Icons.grain_rounded,
          ),
          _buildDivider(),
          _buildItem(
            label: 'Fat',
            value: fatG,
            unit: 'g',
            color: AppColors.fat,
            icon: Icons.opacity_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String label,
    required double value,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, val, child) {
            final formatted = val >= 100
                ? val.round().toString()
                : val.toStringAsFixed(1);
            return Text(
              '$formatted $unit',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 32, color: AppColors.borderLight);
  }
}
