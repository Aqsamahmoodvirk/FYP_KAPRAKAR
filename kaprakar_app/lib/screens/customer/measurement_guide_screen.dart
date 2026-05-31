import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class MeasurementGuideScreen extends StatelessWidget {
  const MeasurementGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.measurementGuide)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.howToMeasure,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppLocalizations.of(context)!.measurementGuideInstruction,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            _buildSectionHeader(context, AppLocalizations.of(context)!.upperBody),
            _GuideItem(title: AppLocalizations.of(context)!.shoulderGuideTitle, description: AppLocalizations.of(context)!.shoulderGuideDesc),
            _GuideItem(title: AppLocalizations.of(context)!.chestGuideTitle, description: AppLocalizations.of(context)!.chestGuideDesc),
            _GuideItem(title: AppLocalizations.of(context)!.waistGuideTitle, description: AppLocalizations.of(context)!.waistGuideDesc),
            _GuideItem(title: AppLocalizations.of(context)!.hipGuideTitle, description: AppLocalizations.of(context)!.hipGuideDesc),
            _GuideItem(title: AppLocalizations.of(context)!.neckGuideTitle, description: AppLocalizations.of(context)!.neckGuideDesc),

            const SizedBox(height: AppSpacing.lg),
            _buildSectionHeader(context, AppLocalizations.of(context)!.sleevesAndLengths),
            _GuideItem(title: AppLocalizations.of(context)!.sleeveGuideTitle, description: AppLocalizations.of(context)!.sleeveGuideDesc),
            _GuideItem(title: AppLocalizations.of(context)!.armholeGuideTitle, description: AppLocalizations.of(context)!.armholeGuideDesc),
            _GuideItem(title: AppLocalizations.of(context)!.kameezGuideTitle, description: AppLocalizations.of(context)!.kameezGuideDesc),

            const SizedBox(height: AppSpacing.lg),
            _buildSectionHeader(context, AppLocalizations.of(context)!.lowerBody),
            _GuideItem(title: AppLocalizations.of(context)!.trouserGuideTitle, description: AppLocalizations.of(context)!.trouserGuideDesc),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final String title;
  final String description;

  const _GuideItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
