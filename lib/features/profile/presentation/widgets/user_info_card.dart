import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/theme/app_radius.dart';
import 'package:bite_front_end/features/profile/data/models/user_profile_response_model.dart';
import 'package:flutter/material.dart';

class UserInfoCard extends StatelessWidget {
  final UserProfileResponseModel profile;

  const UserInfoCard({super.key, required this.profile});

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
            'Physical Attributes & Activity',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context: context,
            label: 'Age',
            value: '${profile.age} yrs',
            icon: Icons.cake_outlined,
            isDark: isDark,
          ),
          const Divider(height: 16),
          _buildInfoRow(
            context: context,
            label: 'Height',
            value: '${profile.heightCm.round()} cm',
            icon: Icons.height_rounded,
            isDark: isDark,
          ),
          const Divider(height: 16),
          _buildInfoRow(
            context: context,
            label: 'Weight',
            value: '${profile.weightKg.toStringAsFixed(1)} kg',
            icon: Icons.monitor_weight_outlined,
            isDark: isDark,
          ),
          const Divider(height: 16),
          _buildInfoRow(
            context: context,
            label: 'Gender',
            value: profile.gender.isNotEmpty
                ? profile.gender[0].toUpperCase() + profile.gender.substring(1)
                : 'Male',
            icon: Icons.person_outline,
            isDark: isDark,
          ),
          const Divider(height: 16),
          _buildInfoRow(
            context: context,
            label: 'Activity Level',
            value: _formatActivityLabel(profile.activityLevel),
            icon: Icons.directions_run_rounded,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextMuted,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  String _formatActivityLabel(String levelKey) {
    switch (levelKey.toLowerCase()) {
      case 'sedentary':
        return 'Sedentary (Little/No exercise)';
      case 'light':
        return 'Lightly Active (1-3 days/wk)';
      case 'moderate':
        return 'Moderately Active (3-5 days/wk)';
      case 'active':
        return 'Active (6-7 days/wk)';
      case 'very_active':
        return 'Very Active (Hard exercise/job)';
      default:
        return 'Moderately Active';
    }
  }
}
