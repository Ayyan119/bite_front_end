import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BiteLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const BiteLogo({
    super.key,
    this.size = 44.0,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? AppColors.lightTextPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.08),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/bite_logo.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    'b',
                    style: TextStyle(
                      fontSize: size * 0.6,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'sans-serif',
                      height: 1.0,
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
                    fontWeight: FontWeight.w800,
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
