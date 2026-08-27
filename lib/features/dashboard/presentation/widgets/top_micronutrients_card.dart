import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

enum MicroCategory {
  minerals('Minerals', Icons.bolt_rounded, Color(0xFFEA580C)),
  vitamins('Vitamins', Icons.local_pharmacy_rounded, Color(0xFF9333EA)),
  fats('Fatty Acids', Icons.water_drop_rounded, Color(0xFF059669)),
  hydration('Hydration', Icons.water_rounded, Color(0xFF2563EB)),
  all('All', Icons.grid_view_rounded, Color(0xFF64748B));

  final String label;
  final IconData icon;
  final Color color;

  const MicroCategory(this.label, this.icon, this.color);
}

class TopMicronutrientsCard extends StatefulWidget {
  final Map<String, double> topMicronutrients;

  const TopMicronutrientsCard({super.key, required this.topMicronutrients});

  @override
  State<TopMicronutrientsCard> createState() => _TopMicronutrientsCardState();
}

class _TopMicronutrientsCardState extends State<TopMicronutrientsCard> {
  // Minerals selected by default
  MicroCategory _selectedCategory = MicroCategory.minerals;

  @override
  Widget build(BuildContext context) {
    if (widget.topMicronutrients.isEmpty) {
      return const SizedBox.shrink();
    }

    final allEntries = widget.topMicronutrients.entries.toList();

    // Filter entries based on selected category
    final filteredEntries = _selectedCategory == MicroCategory.all
        ? allEntries
        : allEntries.where((entry) {
            return _categorizeKey(entry.key) == _selectedCategory;
          }).toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final cardBorder = isDark
        ? const BorderSide(color: Color(0xFF262D3E), width: 1.5)
        : const BorderSide(color: Color(0xFFE2E8F0), width: 1.5);
    final titleTextColor = isDark ? Colors.white : AppColors.lightTextPrimary;

    return AppCard(
      backgroundColor: cardBg,
      borderSide: cardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: _selectedCategory.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _selectedCategory.icon,
                  color: _selectedCategory.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Key Micronutrients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: titleTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // --- 1. CATEGORY TAB SELECTOR BAR (Segmented Pill Tab Buttons) ---
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
              borderRadius: AppRadius.pillBorder,
              border: Border.all(
                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: MicroCategory.values.map((category) {
                  final isSelected = category == _selectedCategory;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? category.color : Colors.transparent,
                        borderRadius: AppRadius.pillBorder,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: category.color.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: 15,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextMuted),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // --- 2. NUTRIENT DATA ELEMENTS (Structured Metric Stat Tiles) ---
          if (filteredEntries.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.inputBorder,
                ),
              ),
              child: Center(
                child: Text(
                  'No ${_selectedCategory.label.toLowerCase()} recorded for today.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.lightTextMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: filteredEntries.map((entry) {
                    final category = _categorizeKey(entry.key);
                    final accentColor = category.color;
                    final cleanName = _cleanNutrientName(entry.key);
                    final formattedVal = entry.value.toStringAsFixed(1);

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cleanName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                formattedVal,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  // Classification Logic
  MicroCategory _categorizeKey(String rawKey) {
    final key = rawKey.toLowerCase();

    // Hydration (Water, Fluid, Moisture, Hydration, H2O, Liquid, Beverage, Drink)
    if (key.contains('water') ||
        key.contains('fluid') ||
        key.contains('moisture') ||
        key.contains('hydration') ||
        key.contains('h2o') ||
        key.contains('liquid') ||
        key.contains('beverage') ||
        key.contains('drink')) {
      return MicroCategory.hydration;
    }

    // Fatty Acids (SFA, MUFA, PUFA, Saturated, Monounsaturated, Polyunsaturated, Lipids, Trans, Omega, Cholesterol, Fatty)
    if (key.contains('sfa') ||
        key.contains('mufa') ||
        key.contains('pufa') ||
        key.contains('sat') ||
        key.contains('saturated') ||
        key.contains('monounsat') ||
        key.contains('polyunsat') ||
        key.contains('trans') ||
        key.contains('omega') ||
        key.contains('cholesterol') ||
        key.contains('fatty') ||
        key.contains('lipid') ||
        key.contains('fat')) {
      return MicroCategory.fats;
    }

    // Essential Vitamins
    if (key.contains('niacin') ||
        key.contains('retinol') ||
        key.contains('thiamin') ||
        key.contains('folic') ||
        key.contains('riboflavin') ||
        key.contains('vitamin') ||
        key.contains('lycopene') ||
        key.contains('ascorbic') ||
        key.contains('cobalamin') ||
        key.contains('tocopherol') ||
        key.contains('biotin') ||
        key.contains('choline')) {
      return MicroCategory.vitamins;
    }

    // Minerals & Electrolytes
    if (key.contains('iron') ||
        key.contains(', fe') ||
        key.contains('zinc') ||
        key.contains(', zn') ||
        key.contains('copper') ||
        key.contains(', cu') ||
        key.contains('sodium') ||
        key.contains(', na') ||
        key.contains('potassium') ||
        key.contains(', k') ||
        key.contains('calcium') ||
        key.contains(', ca') ||
        key.contains('magnesium') ||
        key.contains(', mg') ||
        key.contains('selenium') ||
        key.contains('manganese') ||
        key.contains('iodine')) {
      return MicroCategory.minerals;
    }

    return MicroCategory.vitamins; // Default fallback to vitamins category
  }

  String _cleanNutrientName(String raw) {
    return raw
        .replaceAll(', Fe', '')
        .replaceAll(', Zn', '')
        .replaceAll(', Cu', '')
        .replaceAll(', Na', '')
        .replaceAll(', K', '')
        .replaceAll(', Ca', '')
        .replaceAll(', Mg', '');
  }
}
