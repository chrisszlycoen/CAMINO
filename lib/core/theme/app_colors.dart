import 'package:flutter/material.dart';

/// Ultra-Clean Structural Tokens for CAMINO app (Flagship Aesthetic)
class AppColors {
  // Brand: Elegant, mature Deep Forest Green (representing Rwanda, but elite)
  static const Color primary = Color(0xFF0A3D2F); // Deep rich green
  static const Color primaryLight = Color(0xFF1B6A56);
  static const Color secondary = Color(0xFF111111); // True Black
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Crisp Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFFF3B30);   // iOS Red
  static const Color info = Color(0xFF007AFF);    // iOS Blue

  // Surface Colors - Dark Theme (Student/Staff)
  static const Color backgroundDark = Color(0xFF000000); // True OLED Black
  static const Color surfaceDark = Color(0xFF1C1C1E);    // Elevated iOS dark gray
  static const Color surfaceDarkElevated = Color(0xFF2C2C2E);
  
  // Surface Colors - Light Theme (Parent)
  static const Color backgroundLight = Color(0xFFF2F2F7); // iOS grouped background
  static const Color surfaceLight = Color(0xFFFFFFFF);    // Pure White
  static const Color surfaceLightElevated = Color(0xFFFFFFFF);
  
  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E8E93);

  // Text Colors - Light Theme
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF8E8E93);
  
  // Dividers & Borders
  static const Color borderDark = Color(0xFF38383A);
  static const Color borderLight = Color(0xFFE5E5EA);
  
  // Ultra-subtle Apple-style shadows
  static final List<BoxShadow> premiumShadowLight = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
  ];

  static final List<BoxShadow> premiumShadowDark = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 4)),
  ];
}
