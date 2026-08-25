import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Fresh Health Palette (Organic Emerald & Mint)
  static const Color primary = Color(0xFF059669);
  static const Color primaryDark = Color(0xFF047857);
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryContainer = Color(0xFFD1FAE5);

  // Secondary Warm Citrus Palette (Energy & Appetite)
  static const Color secondary = Color(0xFFEA580C);
  static const Color secondaryDark = Color(0xFFC2410C);
  static const Color secondaryLight = Color(0xFFFFEDD5);

  // Tertiary Berry & Antioxidant Accent
  static const Color tertiary = Color(0xFF7C3AED);
  static const Color tertiaryLight = Color(0xFFF3E8FF);

  // Specific Macro Nutritional Colors
  static const Color calories = Color(0xFFEA580C);
  static const Color protein = Color(0xFF2563EB);
  static const Color carbs = Color(0xFFD97706);
  static const Color fat = Color(0xFF059669);

  // High-Contrast Light Theme Surfaces & Text (No White-on-White!)
  static const Color lightBackground = Color(
    0xFFF1F5F9,
  ); // Soft slate porcelain
  static const Color lightSurface = Color(0xFFFFFFFF); // Crisp white card
  static const Color inputFill = Color(
    0xFFF8FAFC,
  ); // Distinct tinted input background
  static const Color inputBorder = Color(0xFFCBD5E1); // Crisp visible border
  static const Color inputBorderFocused = Color(0xFF059669);

  static const Color lightTextPrimary = Color(
    0xFF0F172A,
  ); // Deep Ink Slate (High Contrast)
  static const Color lightTextSecondary = Color(0xFF334155); // Rich Muted Slate
  static const Color lightTextMuted = Color(0xFF64748B); // Subtitle text

  // Dark Mode Surfaces & Text (Fallback)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Status & Utility Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFD97706);
}
