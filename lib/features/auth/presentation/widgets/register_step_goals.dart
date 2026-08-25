import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RegisterStepGoals extends StatelessWidget {
  final String activityLevel;
  final ValueChanged<String> onActivityLevelChanged;
  final String primaryGoal;
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
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select your activity level and fitness target to tailor recommendations.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.lightTextSecondary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Primary Goal',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _GoalCard(
                title: 'Weight Loss',
                subtitle: 'Calorie Deficit',
                icon: Icons.trending_down,
                color: AppColors.secondary,
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
                icon: Icons.balance,
                color: AppColors.carbs,
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
                icon: Icons.fitness_center,
                color: AppColors.protein,
                value: 'muscle_gain',
                selectedValue: primaryGoal,
                onTap: () => onPrimaryGoalChanged('muscle_gain'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Activity Level',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _ActivityTile(
          title: 'Sedentary',
          subtitle: 'Little to no exercise, desk work',
          icon: Icons.weekend_outlined,
          value: 'sedentary',
          selectedValue: activityLevel,
          onTap: () => onActivityLevelChanged('sedentary'),
        ),
        const SizedBox(height: 8),
        _ActivityTile(
          title: 'Lightly Active',
          subtitle: 'Light exercise 1-3 days/week',
          icon: Icons.directions_walk,
          value: 'light',
          selectedValue: activityLevel,
          onTap: () => onActivityLevelChanged('light'),
        ),
        const SizedBox(height: 8),
        _ActivityTile(
          title: 'Moderately Active',
          subtitle: 'Moderate exercise 3-5 days/week',
          icon: Icons.directions_run,
          value: 'moderate',
          selectedValue: activityLevel,
          onTap: () => onActivityLevelChanged('moderate'),
        ),
        const SizedBox(height: 8),
        _ActivityTile(
          title: 'Very Active',
          subtitle: 'Hard exercise 6-7 days/week',
          icon: Icons.directions_bike,
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
  final String value;
  final String selectedValue;
  final VoidCallback onTap;

  const _GoalCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.14)
              : AppColors.inputFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.inputBorder,
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.lightTextPrimary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.lightTextMuted,
                fontWeight: FontWeight.w600,
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
  final String selectedValue;
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
          color: isSelected
              ? AppColors.primaryContainer.withValues(alpha: 0.8)
              : AppColors.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.lightSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primaryDark
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
