import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/theme/app_radius.dart';
import 'package:bite_front_end/features/profile/data/models/user_profile_response_model.dart';
import 'package:flutter/material.dart';

class UserInfoCard extends StatelessWidget {
  final UserProfileResponseModel profile;

  const UserInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final ageText = profile.age > 0 ? '${profile.age} yrs' : '--';
    final heightText = profile.heightCm > 0
        ? '${profile.heightCm.round()} cm'
        : '--';
    final weightText = profile.weightKg > 0
        ? '${profile.weightKg.toStringAsFixed(1)} kg'
        : '--';
    final genderText = profile.gender.isNotEmpty
        ? profile.gender[0].toUpperCase() + profile.gender.substring(1)
        : '--';
    final activityText = _formatActivityLabel(profile.activityLevel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'PHYSICAL ATTRIBUTES & ACTIVITY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: AppRadius.pillBorder,
                ),
                child: const Text(
                  '👤 Body Metrics',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'Age',
            value: ageText,
            icon: Icons.cake_rounded,
            iconBg: const Color(0xFFFFF7ED),
            accentColor: AppColors.secondary,
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(
            label: 'Height',
            value: heightText,
            icon: Icons.height_rounded,
            iconBg: const Color(0xFFEFF6FF),
            accentColor: const Color(0xFF2563EB),
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(
            label: 'Weight',
            value: weightText,
            icon: Icons.monitor_weight_rounded,
            iconBg: const Color(0xFFECFDF5),
            accentColor: const Color(0xFF10B981),
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(
            label: 'Gender',
            value: genderText,
            icon: Icons.person_rounded,
            iconBg: const Color(0xFFF3E8FF),
            accentColor: const Color(0xFF9333EA),
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(
            label: 'Activity Level',
            value: activityText,
            icon: Icons.directions_run_rounded,
            iconBg: const Color(0xFFFEF3C7),
            accentColor: const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: accentColor),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  String _formatActivityLabel(String levelKey) {
    if (levelKey.isEmpty) return '--';
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
        return '--';
    }
  }
}
