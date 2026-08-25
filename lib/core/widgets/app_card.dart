import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderSide? borderSide;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.lg);
    final effectiveBorder =
        borderSide ??
        const BorderSide(color: AppColors.inputBorder, width: 1.5);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.lightSurface,
        borderRadius: AppRadius.xlBorder,
        border: Border.fromBorderSide(effectiveBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.xlBorder,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.xlBorder,
          child: Padding(padding: effectivePadding, child: child),
        ),
      ),
    );
  }
}
