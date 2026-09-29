import 'package:flutter/material.dart';

class AppColors {
  // IES College of Technology - Brand Colors
  static const Color primary = Color(0xFF1A3C6E);       // ICOT Deep Blue
  static const Color primaryLight = Color(0xFF2A5298);  // Lighter blue
  static const Color secondary = Color(0xFFF5A623);     // ICOT Orange/Gold
  static const Color secondaryDark = Color(0xFFE8920F); // Darker orange

  // Dark Theme
  static const Color background = Color(0xFF0D1B2A);
  static const Color surface = Color(0xFF1E2D40);
  static const Color surfaceVariant = Color(0xFF243447);
  static const Color cardColor = Color(0xFF1A2A3A);

  // Accent Colors
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textHint = Color(0xFF607D8B);

  // Attendance Colors
  static const Color attendanceGood = Color(0xFF22C55E);    // >= 75%
  static const Color attendanceWarning = Color(0xFFF59E0B); // 60-75%
  static const Color attendanceLow = Color(0xFFEF4444);     // < 60%

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A3C6E), Color(0xFF2A5298)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0D1B2A), Color(0xFF1A3C6E), Color(0xFF0D1B2A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E2D40), Color(0xFF243447)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
