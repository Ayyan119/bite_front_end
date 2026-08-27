import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RegisterStepGoals extends StatelessWidget {
  final String? activityLevel;
  final ValueChanged<String> onActivityLevelChanged;
  final String? primaryGoal;
  final ValueChanged<String> onPrimaryGoalChanged;

  const RegisterStepGoals({
    super.key,
    required this.activityLevel,
    required this.onActivityLevelChanged,
    required this.primaryGoal,
    required this.onPrimaryGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lifestyle & Goals',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Select your activity level and target to calculate personalized macros. (Optional)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 18),

        const Text(
          'Primary Fitness Goal (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _GoalCard(
                title: 'Weight Loss',
                subtitle: 'Calorie Deficit',
                icon: Icons.trending_down_rounded,
                color: AppColors.secondary,
                bgColor: const Color(0xFFFFF0E5),
                value: 'weight_loss',
                selectedValue: primaryGoal,
                onTap: () => onPrimaryGoalChanged('weight_loss'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _GoalCard(
                title: 'Maintain',
                subtitle: 'Balance Macros',
                icon: Icons.balance_rounded,
                color: AppColors.carbs,
                bgColor: const Color(0xFFFEF3C7),
                value: 'maintenance',
                selectedValue: primaryGoal,
                onTap: () => onPrimaryGoalChanged('maintenance'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _GoalCard(
                title: 'Muscle Gain',
                subtitle: 'High Protein',
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFF0284C7),
                bgColor: const Color(0xFFE0F2FE),
                value: 'muscle_gain',
                selectedValue: primaryGoal,
                onTap: () => onPrimaryGoalChanged('muscle_gain'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        const Text(
          'Daily Activity Level (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        _ActivityTile(
          title: 'Sedentary',
          subtitle: 'Little to no exercise, desk job',
          icon: Icons.weekend_outlined,
          value: 'sedentary',
          selectedValue: activityLevel,
          onTap: () => onActivityLevelChanged('sedentary'),
        ),
        const SizedBox(height: 8),
        _ActivityTile(
          title: 'Lightly Active',
          subtitle: 'Light exercise 1-3 days/week',
          icon: Icons.directions_walk_rounded,
          value: 'light',
          selectedValue: activityLevel,
          onTap: () => onActivityLevelChanged('light'),
        ),
        const SizedBox(height: 8),
        _ActivityTile(
          title: 'Moderately Active',
          subtitle: 'Moderate exercise 3-5 days/week',
          icon: Icons.directions_run_rounded,
          value: 'moderate',
          selectedValue: activityLevel,
          onTap: () => onActivityLevelChanged('moderate'),
        ),
        const SizedBox(height: 8),
        _ActivityTile(
          title: 'Very Active',
          subtitle: 'Hard exercise 6-7 days/week',
          icon: Icons.directions_bike_rounded,
          value: 'active',
          selectedValue: activityLevel,
          onTap: () => onActivityLevelChanged('active'),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String value;
  final String? selectedValue;
  final VoidCallback onTap;

  const _GoalCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : bgColor.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String? selectedValue;
  final VoidCallback onTap;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.secondary : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.w700,
                      color: isSelected
                          ? AppColors.secondary
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
