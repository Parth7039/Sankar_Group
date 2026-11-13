import 'package:flutter/material.dart';
abstract final class AppColors {
  // Brand colours.
  static const burgundy = Color(0xFF861B35);
  static const burgundyDark = Color(0xFF5F1025);
  static const solarGreen = Color(0xFF359653);
  static const solarGreenDark = Color(0xFF267440);

  // Surfaces and text.
  static const background = Color(0xFFF7F8F6);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF202521);
  static const textSecondary = Color(0xFF707870);
  static const border = Color(0xFFE5E9E4);

  // Semantic colours.
  static const success = Color(0xFF278348);
  static const warning = Color(0xFFC18427);
  static const error = Color(0xFFB3261E);

  // Soft brand tints for chips, banners and selected states.
  static const burgundyTint = Color(0xFFF7EDEF);
  static const greenTint = Color(0xFFECF5EE);
}
