import 'package:flutter/material.dart';

class AppColors {
  // TODO: thay hex theo Figma
  static const primary = Color(0xFF3366FF);
  static const background = Color(0xFFF9FAFB);
  static const text = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const card = Colors.white;
  static const error = Color(0xFFEF4444);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static BorderRadius rounded(double r) => BorderRadius.circular(r);
}
