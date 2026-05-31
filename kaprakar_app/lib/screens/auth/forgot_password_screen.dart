import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/app_input_field.dart';
import '../../routes/app_routes.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleSendOtp() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Sent (Mock)')),
      );
      // Navigate back to Login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.forgotPassword),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Text(
                  AppLocalizations.of(context)!.resetPassword,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppLocalizations.of(context)!.enterYourEmailOrPhoneNumberToR,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppInputField(
                  label: AppLocalizations.of(context)!.emailPhone,
                  hint: 'Enter your email or phone',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email or phone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  text: AppLocalizations.of(context)!.sendOtp,
                  onPressed: _handleSendOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
