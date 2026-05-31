import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../routes/app_routes.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 110, bottom: 40, left: 24, right: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.settings_outlined, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Settings &\nPreferences",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _buildSwitchItem(context, Icons.notifications_active_outlined, AppLocalizations.of(context)!.notifications, _notificationsEnabled, (val) {
                    setState(() {
                      _notificationsEnabled = val;
                    });
                  }),
                  const SizedBox(height: AppSpacing.md),
                  _buildSettingsItem(context, Icons.description_outlined, AppLocalizations.of(context)!.termsOfService, () {
                    Navigator.pushNamed(context, AppRoutes.staticContent, arguments: {
                      'title': AppLocalizations.of(context)!.termsOfService,
                      'content': AppLocalizations.of(context)!.termsOfServiceContent,
                      'icon': Icons.description_outlined
                    });
                  }),
                  _buildSettingsItem(context, Icons.privacy_tip_outlined, AppLocalizations.of(context)!.privacyPolicy, () {
                    Navigator.pushNamed(context, AppRoutes.staticContent, arguments: {
                      'title': AppLocalizations.of(context)!.privacyPolicy,
                      'content': AppLocalizations.of(context)!.privacyPolicyContent,
                      'icon': Icons.privacy_tip_outlined
                    });
                  }),
                  _buildSettingsItem(context, Icons.info_outline, AppLocalizations.of(context)!.aboutKapraKar, () {
                    Navigator.pushNamed(context, AppRoutes.staticContent, arguments: {
                      'title': AppLocalizations.of(context)!.aboutKapraKar,
                      'content': "KapraKar is a modern platform seamlessly connecting customers with expert tailors for custom dressmaking.\n\nVersion 1.0.0\n© 2026 KapraKar",
                      'icon': Icons.info_outline
                    });
                  }),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(BuildContext context, IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
        value: value,
        activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        activeColor: Theme.of(context).colorScheme.primary,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? Colors.red : Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDestructive ? Colors.red : AppColors.textPrimary)),
        trailing: isDestructive ? null : Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400)
        ),
        onTap: onTap,
      ),
    );
  }
}
