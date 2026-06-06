import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryOrange = Color(0xFFFF6B2C);
  static const Color secondaryPurple = Color(0xFF7B2CFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF121212);
  static const Color darkText = Color(0xFF121212);
  static const Color greyText = Color(0xFF8E8E93);
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color fieldBorder = Color(0xFFE8E8E8);
  
  // Gradients
  static const Gradient orangePurpleGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      primaryOrange,
      secondaryPurple,
    ],
  );

  static const Gradient buttonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFF824D),
      primaryOrange,
    ],
  );

  static const Gradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      secondaryPurple,
      Color(0xFFA166FF),
    ],
  );

  static const Gradient productBackgroundGradient = RadialGradient(
    colors: [
      Color(0xFFFF8E5E),
      primaryOrange,
    ],
  );

  static const Gradient bottomWaveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      secondaryPurple,
      primaryOrange,
    ],
  );
}
