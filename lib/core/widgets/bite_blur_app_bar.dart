import 'dart:ui';
import 'package:flutter/material.dart';

/// Glassmorphic translucent blurry background for top AppBars across the application,
/// matching the exact blur and border styling of [BiteFloatingNavBar].
class BiteBlurAppBarBackground extends StatelessWidget {
  const BiteBlurAppBarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF11141E).withValues(alpha: 0.65)
                : Colors.white.withValues(alpha: 0.42),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? const Color(0x33FFFFFF)
                    : Colors.white.withValues(alpha: 0.75),
                width: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
