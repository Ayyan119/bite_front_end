import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BiteLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const BiteLogo({
    super.key,
    this.size = 40.0,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor =
        textColor ?? Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/bite_logo.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback lowercase "b" icon painter if asset is loading or missing
                return Container(
                  color: AppColors.primaryContainer,
                  alignment: Alignment.center,
                  child: Text(
                    'b',
                    style: TextStyle(
                      fontSize: size * 0.65,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.25),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'b',
                  style: TextStyle(
                    fontSize: size * 0.7,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: -1.0,
                  ),
                ),
                TextSpan(
                  text: 'ite',
                  style: TextStyle(
                    fontSize: size * 0.7,
                    fontWeight: FontWeight.w700,
                    color: effectiveTextColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
