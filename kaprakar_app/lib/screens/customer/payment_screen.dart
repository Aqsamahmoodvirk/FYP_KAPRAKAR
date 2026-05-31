import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../theme/app_spacing.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.payment)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const Spacer(),
            PrimaryButton(text: AppLocalizations.of(context)!.payNow, onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
