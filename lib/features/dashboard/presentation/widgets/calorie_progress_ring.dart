import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

class CalorieProgressRing extends StatelessWidget {
  final double targetCalories;
  final double consumedCalories;
  final double remainingCalories;

  const CalorieProgressRing({
    super.key,
    required this.targetCalories,
    required this.consumedCalories,
    required this.remainingCalories,
  });

  @override
  Widget build(BuildContext context) {
    final progress = targetCalories > 0
        ? (consumedCalories / targetCalories).clamp(0.0, 1.0)
        : 0.0;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(180, 180),
                  painter: _RingPainter(progress: progress),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: AppColors.calories,
                      size: 26,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      consumedCalories.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.lightTextPrimary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'of ${targetCalories.toInt()} kcal',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: remainingCalories >= 0
                  ? AppColors.secondaryLight
                  : AppColors.errorContainer,
              borderRadius: AppRadius.pillBorder,
              border: Border.all(
                color: remainingCalories >= 0
                    ? AppColors.secondary.withValues(alpha: 0.3)
                    : AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  remainingCalories >= 0
                      ? Icons.bolt
                      : Icons.warning_amber_rounded,
                  size: 16,
                  color: remainingCalories >= 0
                      ? AppColors.secondaryDark
                      : AppColors.error,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  remainingCalories >= 0
                      ? '${remainingCalories.toInt()} kcal remaining'
                      : '${(-remainingCalories).toInt()} kcal over target',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: remainingCalories >= 0
                        ? AppColors.secondaryDark
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final radius = (size.width - 16) / 2;
    const strokeWidth = 14.0;

    // Track Paint
    final trackPaint = Paint()
      ..color = AppColors.inputBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active Progress Gradient Paint
    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.secondary, AppColors.calories],
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

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
