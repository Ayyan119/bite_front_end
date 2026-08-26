import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.black,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryLight,
        tertiary: AppColors.tertiary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme)
        .copyWith(
          displayLarge: GoogleFonts.spaceGrotesk(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          displayMedium: GoogleFonts.spaceGrotesk(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          headlineLarge: GoogleFonts.spaceGrotesk(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
          headlineMedium: GoogleFonts.spaceGrotesk(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
          titleLarge: GoogleFonts.spaceGrotesk(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
          titleMedium: GoogleFonts.spaceGrotesk(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: GoogleFonts.plusJakartaSans(
            color: AppColors.darkTextPrimary,
          ),
          bodyMedium: GoogleFonts.plusJakartaSans(
            color: AppColors.darkTextSecondary,
          ),
          bodySmall: GoogleFonts.plusJakartaSans(
            color: AppColors.darkTextMuted,
          ),
        );

    return baseTheme.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 2,
        scrolledUnderElevation: 4,
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Color(0x66000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.capsuleActiveWhite,
          foregroundColor: AppColors.capsuleActiveDarkText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        labelStyle: const TextStyle(
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: AppColors.darkTextMuted,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColors.inputBorderFocused,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFE2F1FF),
        onPrimaryContainer: AppColors.primary,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFF1F5F9),
        tertiary: AppColors.tertiary,
        surface: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme)
        .copyWith(
          displayLarge: GoogleFonts.spaceGrotesk(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          displayMedium: GoogleFonts.spaceGrotesk(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          headlineLarge: GoogleFonts.spaceGrotesk(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
          headlineMedium: GoogleFonts.spaceGrotesk(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
          titleLarge: GoogleFonts.spaceGrotesk(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
          titleMedium: GoogleFonts.spaceGrotesk(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: GoogleFonts.plusJakartaSans(
            color: AppColors.lightTextPrimary,
          ),
          bodyMedium: GoogleFonts.plusJakartaSans(
            color: AppColors.lightTextSecondary,
          ),
          bodySmall: GoogleFonts.plusJakartaSans(
            color: AppColors.lightTextMuted,
          ),
        );

    return baseTheme.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 2,
        scrolledUnderElevation: 4,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Color(0x11000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        labelStyle: const TextStyle(
          color: AppColors.lightTextSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          color: AppColors.lightTextMuted,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
    );
  }
}
