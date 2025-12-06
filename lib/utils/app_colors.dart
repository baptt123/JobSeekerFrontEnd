// lib/utils/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Màu chính (Brand Colors)
  static const Color primary = Color(0xFF4338CA); // Indigo
  static const Color accent = Color(0xFF8B5CF6); // Violet (cho AI)

  // Màu nền (Backgrounds)
  static const Color backgroundLight = Color(0xFFF3F4F6);
  static const Color backgroundDark = Color(0xFF14131F);

  // Màu Card
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1F2937); // Gray-800

  // Gradient
  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF14131F), Color(0xFF2A0D45)],
  );
}