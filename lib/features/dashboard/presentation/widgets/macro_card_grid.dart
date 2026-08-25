import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/daily_dashboard_response_model.dart';

class MacroCardGrid extends StatelessWidget {
  final MacroProgressModel protein;
  final MacroProgressModel carbs;
  final MacroProgressModel fat;

  const MacroCardGrid({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MacroCard(
            title: 'Protein',
            consumed: protein.consumed,
            target: protein.target,
            color: AppColors.protein,
            backgroundColor: AppColors.protein.withValues(alpha: 0.1),
            icon: Icons.fitness_center,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MacroCard(
            title: 'Carbs',
            consumed: carbs.consumed,
            target: carbs.target,
            color: AppColors.carbs,
            backgroundColor: AppColors.carbs.withValues(alpha: 0.1),
            icon: Icons.grain,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MacroCard(
            title: 'Fat',
            consumed: fat.consumed,
            target: fat.target,
            color: AppColors.fat,
            backgroundColor: AppColors.fat.withValues(alpha: 0.1),
            icon: Icons.local_florist,
          ),
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String title;
  final double consumed;
  final double target;
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  const _MacroCard({
    required this.title,
    required this.consumed,
    required this.target,
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: AppRadius.smBorder,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${consumed.toStringAsFixed(1)}g',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.lightTextPrimary,
            ),
          ),
          Text(
            'of ${target.toStringAsFixed(0)}g',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.pillBorder,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.inputBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
