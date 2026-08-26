import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
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
            color: AppColors.secondary,
            icon: Icons.local_fire_department_rounded,
          ),
          _buildDivider(),
          _buildItem(
            label: 'Protein',
            value: proteinG,
            unit: 'g',
            color: const Color(0xFF0284C7),
            icon: Icons.fitness_center_rounded,
          ),
          _buildDivider(),
          _buildItem(
            label: 'Carbs',
            value: carbsG,
            unit: 'g',
            color: const Color(0xFFD97706),
            icon: Icons.grain_rounded,
          ),
          _buildDivider(),
          _buildItem(
            label: 'Fat',
            value: fatG,
            unit: 'g',
            color: const Color(0xFFE11D48),
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
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 12, color: color),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
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
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 32, color: const Color(0xFFE2E8F0));
  }
}
