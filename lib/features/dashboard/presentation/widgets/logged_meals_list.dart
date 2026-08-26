import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/daily_dashboard_response_model.dart';

class LoggedMealsList extends StatelessWidget {
  final List<LoggedMealSummaryModel> meals;

  const LoggedMealsList({super.key, required this.meals});

  String _getMealCategoryImagePath(String type, String? caption) {
    final t = type.toLowerCase();
    final c = (caption ?? '').toLowerCase();

    if (t == 'breakfast' ||
        c.contains('breakfast') ||
        c.contains('egg') ||
        c.contains('pancake') ||
        c.contains('toast') ||
        c.contains('cereal')) {
      return 'assets/images/breakfast_category.jpg';
    }
    if (t == 'lunch' ||
        c.contains('lunch') ||
        c.contains('salad') ||
        c.contains('sandwich') ||
        c.contains('biryani') ||
        c.contains('rice')) {
      return 'assets/images/lunch_category.jpg';
    }
    if (t == 'dinner' ||
        c.contains('dinner') ||
        c.contains('steak') ||
        c.contains('curry') ||
        c.contains('pasta') ||
        c.contains('pizza')) {
      return 'assets/images/dinner_category.jpg';
    }
    if (t == 'drink' ||
        t == 'beverage' ||
        c.contains('drink') ||
        c.contains('beverage') ||
        c.contains('smoothie') ||
        c.contains('juice') ||
        c.contains('water') ||
        c.contains('glass') ||
        c.contains('coffee') ||
        c.contains('tea')) {
      return 'assets/images/drink_category.jpg';
    }
    return 'assets/images/snack_category.jpg';
  }

  String _getMealCategoryLabel(String type, String? caption) {
    final path = _getMealCategoryImagePath(type, caption);
    if (path.contains('breakfast')) return '🥞 Breakfast';
    if (path.contains('lunch')) return '🥗 Lunch';
    if (path.contains('dinner')) return '🍲 Dinner';
    if (path.contains('drink')) return '🍹 Drink';
    return '🍿 Snack';
  }

  String _cleanMealTitle(String? userCaption, String mealType) {
    if (userCaption == null || userCaption.trim().isEmpty) {
      return mealType[0].toUpperCase() + mealType.substring(1);
    }

    var text = userCaption.trim();
    // Strip out "(Uploaded at ...)", "(Upload...)", "(Uploaded ...)", timestamp strings
    text = text.replaceAll(
      RegExp(
        r'\s*\([^)]*(?:upload|at|\d{4}-\d{2})[^)]*\)',
        caseSensitive: false,
      ),
      '',
    );
    text = text.replaceAll(
      RegExp(r'\s*\(?\s*uploaded?\s*at\s*[^)]*\)?', caseSensitive: false),
      '',
    );
    text = text.replaceAll(
      RegExp(r'\s*\(?\s*upload[^\)]*\)?', caseSensitive: false),
      '',
    );
    text = text.replaceAll(
      RegExp(r'\s*\d{4}-\d{2}-\d{2}.*$', caseSensitive: false),
      '',
    );
    text = text.trim();

    if (text.isEmpty) {
      return mealType[0].toUpperCase() + mealType.substring(1);
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final cardBorder = isDark
        ? const BorderSide(color: Color(0xFF262D3E), width: 1.0)
        : const BorderSide(color: Color(0xFFE2E8F0), width: 1.0);
    final primaryTextColor = isDark ? Colors.white : AppColors.lightTextPrimary;

    if (meals.isEmpty) {
      return AppCard(
        backgroundColor: cardBg,
        borderSide: cardBorder,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryContainer
                    : AppColors.pastelMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_outlined,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Meals Logged Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Snap a picture of your food or use AI Chat to log your first meal of the day.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Logged Meals",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryContainer
                    : AppColors.pastelMint,
                borderRadius: AppRadius.pillBorder,
              ),
              child: Text(
                '${meals.length} ${meals.length == 1 ? 'meal' : 'meals'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: meals.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final meal = meals[index];
            final imagePath = _getMealCategoryImagePath(
              meal.mealType,
              meal.userCaption,
            );
            final categoryLabel = _getMealCategoryLabel(
              meal.mealType,
              meal.userCaption,
            );

            return AppCard(
              backgroundColor: cardBg,
              borderSide: cardBorder,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Category Artwork Illustration Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      imagePath,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 56,
                          height: 56,
                          color: isDark
                              ? AppColors.primaryContainer
                              : AppColors.pastelMint,
                          child: const Icon(
                            Icons.restaurant_rounded,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Meal Info & Macro Pills
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Tag
                        Text(
                          categoryLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Meal Title
                        Text(
                          _cleanMealTitle(meal.userCaption, meal.mealType),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Macro Pills
                        Row(
                          children: [
                            _MacroPill(
                              label: '${meal.proteinG.toInt()}g P',
                              color: AppColors.protein,
                            ),
                            const SizedBox(width: 4),
                            _MacroPill(
                              label: '${meal.carbsG.toInt()}g C',
                              color: AppColors.carbs,
                            ),
                            const SizedBox(width: 4),
                            _MacroPill(
                              label: '${meal.fatG.toInt()}g F',
                              color: AppColors.fat,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Total Calories (Meal timestamp removed per request!)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${meal.calories.toInt()} kcal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.calories,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MacroPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
