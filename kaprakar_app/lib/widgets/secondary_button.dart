import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.accent, width: 1.5), // Gold border
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pillRadius, // 30
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.buttonText.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
