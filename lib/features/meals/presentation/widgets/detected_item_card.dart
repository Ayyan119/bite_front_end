import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../data/models/meal_analysis_response_model.dart';

class DetectedItemCard extends StatefulWidget {
  final DetectedItemModel item;
  final ValueChanged<double> onPortionChanged;
  final VoidCallback onDelete;

  const DetectedItemCard({
    super.key,
    required this.item,
    required this.onPortionChanged,
    required this.onDelete,
  });

  @override
  State<DetectedItemCard> createState() => _DetectedItemCardState();
}

class _DetectedItemCardState extends State<DetectedItemCard> {
  bool _isTappedMinus = false;
  bool _isTappedPlus = false;

  void _increment() {
    setState(() => _isTappedPlus = true);
    widget.onPortionChanged(widget.item.portionAmount + 0.5);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isTappedPlus = false);
    });
  }

  void _decrement() {
    if (widget.item.portionAmount <= 0.5) return;
    setState(() => _isTappedMinus = true);
    widget.onPortionChanged(widget.item.portionAmount - 0.5);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isTappedMinus = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.foodName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.gramWeight.round()}g • ${item.calories.round()} kcal',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Quantity Stepper
              Row(
                children: [
                  GestureDetector(
                    onTap: _decrement,
                    child: AnimatedScale(
                      scale: _isTappedMinus ? 0.88 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          borderRadius: AppRadius.smBorder,
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 16,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${item.portionAmount % 1 == 0 ? item.portionAmount.round() : item.portionAmount} ${item.portionUnit}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _increment,
                    child: AnimatedScale(
                      scale: _isTappedPlus ? 0.88 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: AppRadius.smBorder,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.error,
                    ),
                    onPressed: widget.onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Macro Badges
          Row(
            children: [
              _buildMacroBadge(
                'Protein',
                '${item.proteinG.toStringAsFixed(1)}g',
                AppColors.protein,
              ),
              const SizedBox(width: 8),
              _buildMacroBadge(
                'Carbs',
                '${item.carbsG.toStringAsFixed(1)}g',
                AppColors.carbs,
              ),
              const SizedBox(width: 8),
              _buildMacroBadge(
                'Fat',
                '${item.fatG.toStringAsFixed(1)}g',
                AppColors.fat,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.smBorder,
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
