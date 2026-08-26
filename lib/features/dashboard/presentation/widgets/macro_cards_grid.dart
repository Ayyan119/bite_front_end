import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

class MacroCardsGrid extends StatelessWidget {
  final double currentProteinG;
  final double targetProteinG;
  final double currentCarbsG;
  final double targetCarbsG;
  final double currentFatG;
  final double targetFatG;

  const MacroCardsGrid({
    super.key,
    required this.currentProteinG,
    required this.targetProteinG,
    required this.currentCarbsG,
    required this.targetCarbsG,
    required this.currentFatG,
    required this.targetFatG,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveProteinTarget = targetProteinG > 0 ? targetProteinG : 50.0;
    final effectiveCarbsTarget = targetCarbsG > 0 ? targetCarbsG : 275.0;
    final effectiveFatTarget = targetFatG > 0 ? targetFatG : 67.0;

    return Row(
      children: [
        Expanded(
          child: _buildMacroItem(
            context: context,
            label: 'Protein',
            current: currentProteinG,
            target: effectiveProteinTarget,
            color: AppColors.protein,
            icon: Icons.bolt_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMacroItem(
            context: context,
            label: 'Carbs',
            current: currentCarbsG,
            target: effectiveCarbsTarget,
            color: AppColors.carbs,
            icon: Icons.grain_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMacroItem(
            context: context,
            label: 'Fat',
            current: currentFatG,
            target: effectiveFatTarget,
            color: AppColors.fat,
            icon: Icons.water_drop_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroItem({
    required BuildContext context,
    required String label,
    required double current,
    required double target,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    final containerBg = isDark ? const Color(0xFF131722) : Colors.white;
    final titleTextColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final trackColor = isDark
        ? const Color(0xFF1E2435)
        : const Color(0xFFF1F5F9);
    final borderColor = isDark
        ? color.withValues(alpha: 0.3)
        : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? color.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  key: ValueKey('macro_title_$label'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: titleTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${current.round()}g',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: ' / ${target.round()}g',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, animVal, child) {
              return ClipRRect(
                borderRadius: AppRadius.pillBorder,
                child: LinearProgressIndicator(
                  value: animVal,
                  minHeight: 6,
                  backgroundColor: trackColor,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
