import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../routes/app_routes.dart';
import '../../widgets/primary_button.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.selectLanguage)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Spacer(),
            Text(AppLocalizations.of(context)!.chooseYourPreferredLanguage, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              text: AppLocalizations.of(context)!.english,
              onPressed: () {
                // Save 'en' preference (mock)
                Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              text: '\u0627\u0631\u062F\u0648',
              onPressed: () {
                 // Save 'ur' preference (mock)
                Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
