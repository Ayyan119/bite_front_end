import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/bite_fade_slide.dart';
import '../providers/meal_analysis_notifier.dart';
import '../providers/meal_providers.dart';
import '../widgets/camera_preview_card.dart';
import '../widgets/meal_type_selector.dart';
import '../widgets/vision_scanning_overlay.dart';

class MealIngestionScreen extends ConsumerStatefulWidget {
  const MealIngestionScreen({super.key});

  @override
  ConsumerState<MealIngestionScreen> createState() =>
      _MealIngestionScreenState();
}

class _MealIngestionScreenState extends ConsumerState<MealIngestionScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        ref.read(mealAnalysisNotifierProvider.notifier).setSelectedFile(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _analyzeMeal() async {
    final notifier = ref.read(mealAnalysisNotifierProvider.notifier);
    notifier.setCaption(_captionController.text);
    await notifier.analyzeMeal();

    final state = ref.read(mealAnalysisNotifierProvider);
    if (state.status == MealAnalysisStatus.review && mounted) {
      context.push('/meals/review');
    } else if (state.status == MealAnalysisStatus.failure && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Analysis failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealAnalysisNotifierProvider);
    final notifier = ref.read(mealAnalysisNotifierProvider.notifier);
    final hasImage =
        state.selectedFile != null ||
        (state.imageUrl != null && state.imageUrl!.trim().isNotEmpty);
    final isAnalyzing = state.status == MealAnalysisStatus.analyzing;
    final canAnalyze = hasImage && !isAnalyzing;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Integrated Page Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'LOG YOUR MEAL',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Instant AI Photo & Description Analysis',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          if (state.selectedFile != null ||
                              state.userCaption.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _captionController.clear();
                                notifier.reset();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.refresh_rounded,
                                      size: 14,
                                      color: AppColors.secondary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Reset',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Image Selection Card with Staggered Entrance
                      BiteFadeSlide(
                        delay: Duration.zero,
                        child: CameraPreviewCard(
                          selectedFile: state.selectedFile,
                          imageUrl: state.imageUrl,
                          isAnalyzing: isAnalyzing,
                          onPickCamera: () => _pickImage(ImageSource.camera),
                          onPickGallery: () => _pickImage(ImageSource.gallery),
                          onClearImage: () => notifier.setSelectedFile(null),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Meal Type Selector with Staggered Entrance
                      BiteFadeSlide(
                        delay: const Duration(milliseconds: 100),
                        child: MealTypeSelector(
                          selectedMealType: state.selectedMealType,
                          onSelected: (type) => notifier.setMealType(type),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Text Description Input with Staggered Entrance
                      BiteFadeSlide(
                        delay: const Duration(milliseconds: 200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MEAL DESCRIPTION (OPTIONAL)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _captionController,
                                maxLines: 3,
                                style: const TextStyle(
                                  color: AppColors.lightTextPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                decoration: const InputDecoration(
                                  hintText:
                                      'e.g., 2 scrambled eggs with 1 slice toast and black coffee...',
                                  hintStyle: TextStyle(
                                    color: AppColors.lightTextMuted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                                onChanged: (val) => notifier.setCaption(val),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Quick Suggestion Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildPromptChip('2 Eggs & Toast 🍳'),
                                  const SizedBox(width: 8),
                                  _buildPromptChip('Chicken Salad 🥗'),
                                  const SizedBox(width: 8),
                                  _buildPromptChip('Protein Shake 🥤'),
                                  const SizedBox(width: 8),
                                  _buildPromptChip('Avocado Toast 🥑'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Primary Action Button (Flame Orange Glow Pill when image selected, Muted Slate when disabled)
                      BiteFadeSlide(
                        delay: const Duration(milliseconds: 300),
                        child: GestureDetector(
                          onTap: canAnalyze ? _analyzeMeal : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: canAnalyze
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.secondary,
                                        Color(0xFFFF7700),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: canAnalyze
                                  ? null
                                  : const Color(0xFFE2E8F0),
                              borderRadius: AppRadius.pillBorder,
                              boxShadow: canAnalyze
                                  ? [
                                      BoxShadow(
                                        color: AppColors.secondary.withValues(
                                          alpha: 0.45,
                                        ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 5),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isAnalyzing
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 20,
                                        color: canAnalyze
                                            ? Colors.white
                                            : const Color(0xFF94A3B8),
                                      ),
                                const SizedBox(width: 10),
                                Text(
                                  isAnalyzing
                                      ? 'ANALYZING MEAL WITH AI...'
                                      : (!hasImage
                                            ? 'SELECT AN IMAGE TO ANALYZE'
                                            : 'ANALYZE MEAL WITH AI'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    color: canAnalyze
                                        ? Colors.white
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // Scanning Overlay when analyzing
            if (isAnalyzing) const VisionScanningOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _captionController.text = label;
        });
        ref.read(mealAnalysisNotifierProvider.notifier).setCaption(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
