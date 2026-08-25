import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
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
    final isAnalyzing = state.status == MealAnalysisStatus.analyzing;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Log Your Meal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (state.selectedFile != null || state.userCaption.isNotEmpty)
            TextButton(
              onPressed: () {
                _captionController.clear();
                notifier.reset();
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      const Text(
                        'Take a photo or describe what you ate for AI Vision analysis',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.lightTextMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Image Selection Card
                      CameraPreviewCard(
                        selectedFile: state.selectedFile,
                        imageUrl: state.imageUrl,
                        onPickCamera: () => _pickImage(ImageSource.camera),
                        onPickGallery: () => _pickImage(ImageSource.gallery),
                        onClearImage: () => notifier.setSelectedFile(null),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Meal Type Selector
                      MealTypeSelector(
                        selectedMealType: state.selectedMealType,
                        onSelected: (type) => notifier.setMealType(type),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Text Caption Input
                      const Text(
                        'Text Description (Optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _captionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'e.g. 2 scrambled eggs with 1 slice toast and black coffee',
                          fillColor: AppColors.inputFill,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.mdBorder,
                            borderSide: const BorderSide(
                              color: AppColors.inputBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.mdBorder,
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (val) => notifier.setCaption(val),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Primary Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: isAnalyzing ? null : _analyzeMeal,
                          icon: isAnalyzing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome, size: 20),
                          label: Text(
                            isAnalyzing
                                ? 'Analyzing...'
                                : 'Analyze Meal with AI',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.lgBorder,
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
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
}
