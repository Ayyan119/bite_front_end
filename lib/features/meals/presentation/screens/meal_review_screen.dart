import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/bite_fade_slide.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../home/presentation/providers/home_tab_provider.dart';
import '../providers/meal_analysis_notifier.dart';
import '../providers/meal_providers.dart';
import '../widgets/detected_item_card.dart';
import '../widgets/macro_summary_bar.dart';
import '../widgets/meal_success_dialog.dart';

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
    final stateBefore = ref.read(mealAnalysisNotifierProvider);
    final success = await notifier.confirmMeal();

    if (success && mounted) {
      setState(() => _isSuccessAnim = true);
      _pulseController.forward();

      await MealSuccessDialog.show(
        context,
        totalCalories: stateBefore.totalCalories,
        mealType: stateBefore.selectedMealType,
        itemCount: stateBefore.items.length,
        onViewDashboard: () {
          if (mounted) {
            notifier.reset();
            ref.read(selectedDashboardDateProvider.notifier).state =
                DateTime.now();
            final todayStr = formatDateString(DateTime.now());
            ref.invalidate(dailyDashboardProvider(todayStr));
            ref.read(homeTabIndexProvider.notifier).state = 0;
            context.go('/home');
          }
        },
        onCloseToCameraMeal: () {
          if (mounted) {
            notifier.reset();
            final todayStr = formatDateString(DateTime.now());
            ref.invalidate(dailyDashboardProvider(todayStr));
            ref.read(homeTabIndexProvider.notifier).state = 1;
            context.go('/home');
          }
        },
      );
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealAnalysisNotifierProvider);
    final notifier = ref.read(mealAnalysisNotifierProvider.notifier);
    final hasItems = state.items.isNotEmpty;
    final isCommitting = state.status == MealAnalysisStatus.committing;
    final canConfirm = hasItems && !isCommitting;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'REVIEW & CONFIRM MEAL',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: AppColors.lightTextPrimary,
          ),
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
                          BiteFadeSlide(
                            delay: Duration.zero,
                            child: Container(
                              height: 170,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
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
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // Meal Type & Item Count Badge
                        BiteFadeSlide(
                          delay: const Duration(milliseconds: 80),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: AppRadius.pillBorder,
                                ),
                                child: Text(
                                  state.selectedMealType.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                '${state.items.length} Food Item(s) Detected',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Animated Macro Summary Bar
                        BiteFadeSlide(
                          delay: const Duration(milliseconds: 160),
                          child: MacroSummaryBar(
                            calories: state.totalCalories,
                            proteinG: state.totalProtein,
                            carbsG: state.totalCarbs,
                            fatG: state.totalFat,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Detected Items Section Title & List
                        BiteFadeSlide(
                          delay: const Duration(milliseconds: 240),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DETECTED FOOD ITEMS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // List of Detected Items
                              if (state.items.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'No food items detected in meal photo.',
                                    style: TextStyle(color: Color(0xFF64748B)),
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
                                        notifier.updateItemPortion(
                                          index,
                                          newAmount,
                                        );
                                      },
                                      onDelete: () =>
                                          notifier.removeItem(index),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Sticky Bottom Confirmation Action Bar
            BiteFadeSlide(
              delay: const Duration(milliseconds: 320),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: canConfirm
                            ? const LinearGradient(
                                colors: [
                                  AppColors.secondary,
                                  Color(0xFFFF7700),
                                ],
                              )
                            : null,
                        color: canConfirm ? null : const Color(0xFFE2E8F0),
                        borderRadius: AppRadius.pillBorder,
                        boxShadow: canConfirm
                            ? [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.38,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: canConfirm ? _confirmMeal : null,
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
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      hasItems
                                          ? Icons.check_rounded
                                          : Icons.block_rounded,
                                      size: 22,
                                      color: canConfirm
                                          ? Colors.white
                                          : const Color(0xFF94A3B8),
                                    )),
                        label: Text(
                          isCommitting
                              ? 'SAVING MEAL LOG...'
                              : (_isSuccessAnim
                                    ? 'MEAL LOGGED!'
                                    : (hasItems
                                          ? 'CONFIRM & LOG MEAL'
                                          : 'NO FOOD ITEMS DETECTED')),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: canConfirm
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: canConfirm
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.pillBorder,
                          ),
                          elevation: 0,
                        ),
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
