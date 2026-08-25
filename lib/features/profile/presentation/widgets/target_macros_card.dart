import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/theme/app_radius.dart';
import 'package:bite_front_end/features/profile/data/models/user_profile_response_model.dart';
import 'package:flutter/material.dart';

class TargetMacrosCard extends StatelessWidget {
  final UserProfileResponseModel profile;

  const TargetMacrosCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
        borderRadius: AppRadius.lgBorder,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Macro Split',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildMacroRow(
            context: context,
            label: 'Protein Target',
            value: '${profile.targetProteinG.round()} g',
            color: AppColors.protein,
            percentage: 0.30,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildMacroRow(
            context: context,
            label: 'Carbs Target',
            value: '${profile.targetCarbsG.round()} g',
            color: AppColors.carbs,
            percentage: 0.50,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildMacroRow(
            context: context,
            label: 'Fat Target',
            value: '${profile.targetFatG.round()} g',
            color: AppColors.fat,
            percentage: 0.20,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
    required double percentage,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: AppRadius.pillBorder,
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: isDark
                ? AppColors.darkBackground
                : AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
