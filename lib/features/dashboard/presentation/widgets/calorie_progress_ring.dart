import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

class CalorieProgressRing extends StatefulWidget {
  final double targetCalories;
  final double consumedCalories;
  final double remainingCalories;
  final VoidCallback? onLogMealPressed;

  const CalorieProgressRing({
    super.key,
    required this.targetCalories,
    required this.consumedCalories,
    required this.remainingCalories,
    this.onLogMealPressed,
  });

  @override
  State<CalorieProgressRing> createState() => _CalorieProgressRingState();
}

class _CalorieProgressRingState extends State<CalorieProgressRing> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSaved = false;

  Future<void> _handleSaveAchievement(BuildContext context) async {
    if (_isSaved) return; // Avoid redundant taps while saving

    setState(() {
      _isSaved = true;
    });

    try {
      final RenderRepaintBoundary? boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null) {
        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        final ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (byteData != null) {
          final Uint8List pngBytes = byteData.buffer.asUint8List();
          final name =
              'bite_daily_target_${DateTime.now().millisecondsSinceEpoch}';
          await Gal.putImageBytes(pngBytes, name: name);
        }
      }
    } catch (e) {
      debugPrint('Error saving daily target card to gallery: $e');
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.stars_rounded, color: AppColors.secondary, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Daily Target Card Saved to Gallery! 🎉',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E2025),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.secondary, width: 1.2),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Auto-unfill reset after 1.6s so the user can save multiple times
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        setState(() {
          _isSaved = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final progress = widget.targetCalories > 0
        ? (widget.consumedCalories / widget.targetCalories).clamp(0.0, 1.0)
        : 0.0;

    final cardBg = isDark ? const Color(0xFF131722) : AppColors.darkSlate;
    final cardBorderColor = isDark
        ? const Color(0xFF262D3E)
        : const Color(0xFF334155);

    return RepaintBoundary(
      key: _repaintKey,
      child: AppCard(
        backgroundColor: cardBg,
        borderSide: BorderSide(color: cardBorderColor, width: 1.0),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header Row with Title and Working Floating Save/Bookmark Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'DAILY TARGET',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Intelligent Macro Balance',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
                // Enhanced Save/Bookmark Button (Fills on save, resets after 1.6s)
                GestureDetector(
                  onTap: () => _handleSaveAchievement(context),
                  child: AnimatedScale(
                    scale: _isSaved ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isSaved
                            ? AppColors.secondary
                            : const Color(0xFF262C3A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isSaved
                              ? AppColors.secondary
                              : const Color(0x33FFFFFF),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isSaved ? AppColors.secondary : Colors.black)
                                    .withValues(alpha: _isSaved ? 0.45 : 0.25),
                            blurRadius: _isSaved ? 12 : 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Central Animated Custom Ring & Counter
            Center(
              child: SizedBox(
                width: 190,
                height: 190,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: progress),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedProgress, child) {
                    final animatedCalories = widget.consumedCalories > 0
                        ? (animatedProgress *
                                  widget.consumedCalories /
                                  (progress > 0 ? progress : 1.0))
                              .round()
                        : 0;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(190, 190),
                          painter: _RingPainter(progress: animatedProgress),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.15,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_fire_department_rounded,
                                color: AppColors.secondary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              animatedCalories.toString(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'of ${widget.targetCalories.toInt()} kcal',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Bottom Floating Action Overlay Pill Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0D14),
                borderRadius: AppRadius.pillBorder,
                border: Border.all(color: const Color(0x33FFFFFF), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.remainingCalories >= 0
                              ? '${widget.remainingCalories.toInt()} kcal remaining'
                              : '${(-widget.remainingCalories).toInt()} kcal over target',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: widget.remainingCalories >= 0
                                ? AppColors.tertiary
                                : AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Tap to analyze meal',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.darkTextMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Beautiful Signature LOG MEAL Action Pill Button
                  GestureDetector(
                    onTap: widget.onLogMealPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.secondary, Color(0xFFFF7700)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppRadius.pillBorder,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'LOG MEAL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;
    const strokeWidth = 16.0;

    // Outer Track Paint (Obsidian dark arc track)
    final trackPaint = Paint()
      ..color = const Color(0xFF1E2435)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      // Active Arc Gradient Shader (Flame Orange into Electric Cyan)
      final activePaint = Paint()
        ..shader = const SweepGradient(
          colors: [
            AppColors.secondary,
            AppColors.tertiary,
            AppColors.secondary,
          ],
          stops: [0.0, 0.7, 1.0],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
