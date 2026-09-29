import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accent — Professional Enterprise SaaS (Accsoft / CollPoll / Canvas)
  static const Color primary = Color(0xFF1E40AF);       // Corporate Royal Blue
  static const Color primaryLight = Color(0xFF3B82F6);  // Bright Accent Blue
  static const Color primaryDark = Color(0xFF1E3A8A);   // Deep Navy

  static const Color accent = Color(0xFF0284C7);        // Precision Sky Cyan
  static const Color accentPurple = Color(0xFF6366F1);  // Modern Indigo
  static const Color accentPink = Color(0xFFEC4899);    // Rose Coral

  // Status & Feedback
  static const Color success = Color(0xFF059669);       // Emerald Green (Crisp Light Mode)
  static const Color successLight = Color(0xFFD1FAE5);  // Soft Emerald Tint
  static const Color warning = Color(0xFFD97706);       // Warm Amber
  static const Color warningLight = Color(0xFFFEF3C7);  // Soft Amber Tint
  static const Color error = Color(0xFFDC2626);         // Crimson Red
  static const Color errorLight = Color(0xFFFEE2E2);    // Soft Red Tint
  static const Color info = Color(0xFF0284C7);          // Informative Blue
  static const Color infoLight = Color(0xFFE0F2FE);     // Soft Blue Tint

  // Clean Light Theme Surfaces (The Preferred Enterprise SaaS Aesthetic)
  static const Color bgLight = Color(0xFFF8FAFC);       // Soft Clean Canvas / Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);  // Pure White Card
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // Secondary Soft Gray / Slate 100
  static const Color borderLight = Color(0xFFE2E8F0);   // Hairline Slate 200 Border
  static const Color borderSubtle = Color(0xFFEEF2F6);  // Ultra-fine Divider

  // Dark Theme Surfaces (Fallback / Night Mode)
  static const Color bgDark = Color(0xFF0F172A);         // Deep Slate 900
  static const Color surfaceDark = Color(0xFF1E293B);    // Slate 800
  static const Color surfaceCardDark = Color(0xFF1E293B);// Elevated Card
  static const Color borderDark = Color(0xFF334155);     // Hairline Border

  // Typography Palette (High-Contrast, Maximum Readability)
  static const Color textDark = Color(0xFF0F172A);      // Primary Headlines (Slate 900)
  static const Color textSecondary = Color(0xFF334155); // Body Text (Slate 700)
  static const Color textMuted = Color(0xFF64748B);     // Subtitles & Captions (Slate 500)
  static const Color textLight = Color(0xFFFFFFFF);     // White text for colored surfaces

  // Enterprise Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardLightGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardDarkGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  // ── PREFERRED MODERN ENTERPRISE LIGHT THEME ─────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textDark,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.borderLight, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
      ),
    );
  }

  // ── EXECUTIVE DARK THEME (FALLBACK) ─────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        secondary: AppColors.accent,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textLight,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
    );
  }
}
