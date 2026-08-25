import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/meal_analysis_response_model.dart';
import '../providers/meal_analysis_notifier.dart';
import '../providers/meal_providers.dart';
import '../widgets/add_item_dialog.dart';
import '../widgets/detected_item_card.dart';
import '../widgets/macro_summary_bar.dart';

class MealReviewScreen extends ConsumerStatefulWidget {
  const MealReviewScreen({super.key});

  @override
  ConsumerState<MealReviewScreen> createState() => _MealReviewScreenState();
}

class _MealReviewScreenState extends ConsumerState<MealReviewScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  bool _isSuccessAnim = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _confirmMeal() async {
    final notifier = ref.read(mealAnalysisNotifierProvider.notifier);
    final success = await notifier.confirmMeal();

    if (success && mounted) {
      setState(() => _isSuccessAnim = true);
      _pulseController.forward();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Meal logged successfully! Dashboard updated.'),
            ],
          ),
          backgroundColor: AppColors.primary,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        notifier.reset();
        context.go('/dashboard');
      }
    } else if (mounted) {
      final state = ref.read(mealAnalysisNotifierProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Failed to confirm meal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _openAddItemDialog() async {
    final newItem = await showDialog<DetectedItemModel>(
      context: context,
      builder: (context) => const AddItemDialog(),
    );
    if (newItem != null) {
      ref.read(mealAnalysisNotifierProvider.notifier).addItem(newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealAnalysisNotifierProvider);
    final notifier = ref.read(mealAnalysisNotifierProvider.notifier);
    final isCommitting = state.status == MealAnalysisStatus.committing;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Review & Confirm Meal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Thumbnail Header (if present)
                        if (state.selectedFile != null ||
                            (state.imageUrl != null &&
                                state.imageUrl!.isNotEmpty)) ...[
                          Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.lgBorder,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: AppRadius.lgBorder,
                              child: Hero(
                                tag: 'meal-image-preview',
                                child: state.selectedFile != null
                                    ? (kIsWeb
                                          ? FutureBuilder<Uint8List>(
                                              future: state.selectedFile!
                                                  .readAsBytes(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return Image.memory(
                                                    snapshot.data!,
                                                    fit: BoxFit.cover,
                                                  );
                                                }
                                                return const SizedBox();
                                              },
                                            )
                                          : Image.file(
                                              File(state.selectedFile!.path),
                                              fit: BoxFit.cover,
                                            ))
                                    : Image.network(
                                        state.imageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // Meal Type & Item Count Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: AppRadius.pillBorder,
                              ),
                              child: Text(
                                state.selectedMealType.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            Text(
                              '${state.items.length} Food Item(s) Detected',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Animated Macro Summary Bar
                        MacroSummaryBar(
                          calories: state.totalCalories,
                          proteinG: state.totalProtein,
                          carbsG: state.totalCarbs,
                          fatG: state.totalFat,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Detected Items Section Title & Add Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Detected Food Items',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _openAddItemDialog,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Item'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // List of Detected Items
                        if (state.items.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            alignment: Alignment.center,
                            child: const Text(
                              'No food items in meal list. Tap "Add Item" to add manually.',
                              style: TextStyle(color: AppColors.lightTextMuted),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              return DetectedItemCard(
                                key: ValueKey('${item.foodName}_$index'),
                                item: item,
                                onPortionChanged: (newAmount) {
                                  notifier.updateItemPortion(index, newAmount);
                                },
                                onDelete: () => notifier.removeItem(index),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Sticky Bottom Confirmation Action Bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: const Border(
                  top: BorderSide(color: AppColors.borderLight),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isCommitting ? null : _confirmMeal,
                      icon: isCommitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : (_isSuccessAnim
                                ? ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: const Icon(
                                      Icons.check_circle,
                                      size: 24,
                                    ),
                                  )
                                : const Icon(Icons.check, size: 22)),
                      label: Text(
                        isCommitting
                            ? 'Saving Meal Log...'
                            : (_isSuccessAnim
                                  ? 'Meal Logged!'
                                  : 'Confirm & Log Meal'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSuccessAnim
                            ? AppColors.success
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.lgBorder,
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
