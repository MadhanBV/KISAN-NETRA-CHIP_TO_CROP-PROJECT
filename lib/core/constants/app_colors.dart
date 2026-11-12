import 'package:flutter/material.dart';

/// Centralized color palette for CHIP TO CROP.
/// Inspired by natural agricultural tones and the official logo.
class AppColors {
  AppColors._();

  // Primary agricultural green (from the core brand logo)
  static const Color primaryGreen = Color(0xFF16422D);
  static const Color primaryLight = Color(0xFF22573D);
  static const Color primaryDark = Color(0xFF0E2C1E);

  // Accent & leaf greens
  static const Color accentGreen = Color(0xFF439A52);
  static const Color lightGreenTint = Color(0xFFEBF5EE);
  static const Color freshGreen = Color(0xFF58B161);

  // Earthy & warm tones
  static const Color warmAmber = Color(0xFFF5A623);
  static const Color earthBrown = Color(0xFF8B6F4E);
  static const Color sunYellow = Color(0xFFFFC940);
  static const Color skyBlue = Color(0xFF4A90D9);
  static const Color softRed = Color(0xFFE05C5C);

  // Backgrounds & surfaces (off-white, natural and calm)
  static const Color background = Color(0xFFF5F6F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color splashBackground = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Typography
  static const Color textPrimary = Color(0xFF19231D);
  static const Color textSecondary = Color(0xFF56655B);
  static const Color textMuted = Color(0xFF7E8D83);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkMuted = Color(0xCCFFFFFF);

  // Indicators & borders
  static const Color primary = primaryGreen;
  static const Color border = borderLight;
  static const Color indicatorActive = Color(0xFF16422D);
  static const Color indicatorInactive = Color(0xFFD6DFD7);
  static const Color borderLight = Color(0xFFE6EAE6);
  static const Color divider = Color(0xFFEEF0ED);

  // Weather card gradient
  static const Color weatherGradientStart = Color(0xFF1A5C3A);
  static const Color weatherGradientEnd = Color(0xFF0E3D26);

  // Navigation
  static const Color navBarBackground = Color(0xFFFFFFFF);
  static const Color navBarActive = Color(0xFF16422D);
  static const Color navBarInactive = Color(0xFF9CA89E);

  // Service card accents
  static const Color qualityCardAccent = Color(0xFF2E7D4F);
  static const Color diseaseCardAccent = Color(0xFFD4763C);
}
