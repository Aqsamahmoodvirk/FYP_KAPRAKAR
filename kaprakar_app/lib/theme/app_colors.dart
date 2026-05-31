import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Modern Heritage Palette
  static const Color primary = Color(0xFF006D77); // Deep Teal/Emerald
  static const Color secondary = Color(0xFFE29578); // Dusty Rose/Peach
  static const Color background = Color(0xFFEDF6F9); // Soft Linen
  static const Color accentGold = Color(0xFFD4AF37); // Accent Gold (Special Status)
  
  // Text
  static const Color textPrimary = Color(0xFF1F2933); // Deep Charcoal
  static const Color textSecondary = Color(0xFF6B7280); // Softer Gray
  static const Color textOnPrimary = Colors.white;
  static const Color textOnDark = Colors.white;

  // Functional
  static const Color error = Color(0xFFD64545); // Soft Red
  static const Color success = primary; // Success matches Primary
  static const Color surface = Colors.white; // Cards/Containers
  static const Color border = Color(0xFFD7E3E8); // Subtle Border

  // Compatibility/Aliases
  static const Color accent = secondary;
  static const Color white = Colors.white;
  static const Color inputFill = surface;
  static const Color inputBorder = secondary;
}
