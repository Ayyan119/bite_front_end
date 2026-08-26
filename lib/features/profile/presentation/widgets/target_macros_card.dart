import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/theme/app_radius.dart';
import 'package:bite_front_end/features/profile/data/models/user_profile_response_model.dart';
import 'package:flutter/material.dart';

class TargetMacrosCard extends StatelessWidget {
  final UserProfileResponseModel profile;

  const TargetMacrosCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final proteinVal = profile.targetProteinG > 0
        ? profile.targetProteinG
        : 50.0;
    final carbsVal = profile.targetCarbsG > 0 ? profile.targetCarbsG : 275.0;
    final fatVal = profile.targetFatG > 0 ? profile.targetFatG : 67.0;

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
                  'TARGET MACRO SPLIT',
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
                  '📊 Daily Distribution',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildMacroRow(
            emoji: '🍗',
            label: 'Protein Target',
            value: '${proteinVal.round()} g',
            color: AppColors.protein,
            bgTint: const Color(0xFFFFF7ED),
            percentage: 0.0, // 0% consumed until user logs food
          ),
          const SizedBox(height: 12),
          _buildMacroRow(
            emoji: '🍞',
            label: 'Carbs Target',
            value: '${carbsVal.round()} g',
            color: AppColors.carbs,
            bgTint: const Color(0xFFFEF3C7),
            percentage: 0.0, // 0% consumed until user logs food
          ),
          const SizedBox(height: 12),
          _buildMacroRow(
            emoji: '🥑',
            label: 'Fat Target',
            value: '${fatVal.round()} g',
            color: AppColors.fat,
            bgTint: const Color(0xFFECFDF5),
            percentage: 0.0, // 0% consumed until user logs food
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow({
    required String emoji,
    required String label,
    required String value,
    required Color color,
    required Color bgTint,
    required double percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: bgTint,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.pillBorder,
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: AppRadius.pillBorder,
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
