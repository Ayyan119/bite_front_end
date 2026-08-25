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
            child: child,
          );
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primaryLight,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'AI Vision Analyzing Food...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
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

    // Laser scanning line
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.0),
          AppColors.primaryLight,
          AppColors.primary.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, scanY, size.width, 3))
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), linePaint);

    // Glowing beam gradient below line
    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.35),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, scanY - 30, size.width, 35));

    canvas.drawRect(Rect.fromLTWH(0, scanY - 30, size.width, 35), beamPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
