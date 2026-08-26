import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class VisionScanningOverlay extends StatefulWidget {
  const VisionScanningOverlay({super.key});

  @override
  State<VisionScanningOverlay> createState() => _VisionScanningOverlayState();
}

class _VisionScanningOverlayState extends State<VisionScanningOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(
      begin: 0.05,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _scanAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ScannerPainter(progress: _scanAnimation.value),
          );
        },
      ),
    );
  }
}

class _ScannerPainter extends CustomPainter {
  final double progress;

  _ScannerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final scanY = size.height * progress;

    // Flame orange laser scanning line
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.secondary.withValues(alpha: 0.0),
          AppColors.secondary,
          const Color(0xFFFF7700),
          AppColors.secondary.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.35, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, scanY, size.width, 3.5))
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), linePaint);

    // Glowing beam gradient below line
    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.secondary.withValues(alpha: 0.40),
          AppColors.secondary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, scanY - 40, size.width, 45));

    canvas.drawRect(Rect.fromLTWH(0, scanY - 40, size.width, 45), beamPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
