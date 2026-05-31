import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class PreviewStitchedDressScreen extends StatelessWidget {
  const PreviewStitchedDressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.previewDress)),
      body: Center(
        child: Text(AppLocalizations.of(context)!.previewStitchedDress, style: AppTextStyles.bodyMedium),
      ),
    );
  }
}
