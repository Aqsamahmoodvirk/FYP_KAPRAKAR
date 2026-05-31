import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Poppins', 
      
      colorScheme: ColorScheme.light(
        surface: AppColors.background,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accentGold,
        onPrimary: AppColors.textOnPrimary, // White on Teal
        onSecondary: AppColors.textPrimary, // Charcoal on Peach (for better contrast? or White?)
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),

      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.primary),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        labelLarge: AppTextStyles.buttonText.copyWith(color: AppColors.textOnPrimary),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          fontSize: 20, 
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pillRadius,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, 
            vertical: AppSpacing.md
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.secondary),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pillRadius,
          ),
           padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, 
            vertical: AppSpacing.md
          ),
        )
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary, 
          textStyle: AppTextStyles.linkText.copyWith(fontWeight: FontWeight.w600),
        )
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill, // White
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.secondary, width: 2.0),
        ),
        errorBorder: const OutlineInputBorder(
             borderRadius: BorderRadius.all(Radius.circular(8.0)), // AppRadius.inputRadius
             borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, 
          vertical: AppSpacing.md
        ),
        // Hints text color
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.surface, // White
        elevation: 2,
        shadowColor: Colors.black12,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
