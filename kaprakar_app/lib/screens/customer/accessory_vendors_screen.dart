import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class AccessoryVendorsScreen extends StatelessWidget {
  const AccessoryVendorsScreen({super.key});

  final List<Map<String, dynamic>> _mockVendors = const [
    {
      'name': 'The Button Boutique',
      'category': 'Buttons',
      'icon': Icons.radio_button_checked,
    },
    {
      'name': 'Lace & Grace',
      'category': 'Laces',
      'icon': Icons.waves,
    },
    {
      'name': 'Latkan Luxuries',
      'category': 'Latkans',
      'icon': Icons.attractions,
    },
    {
      'name': 'Patch Perfect',
      'category': 'Embroidered Patches',
      'icon': Icons.style,
    },
    {
      'name': 'Thread Classics',
      'category': 'Threads & Zippers',
      'icon': Icons.line_style,
    },
    {
      'name': 'Beads & Sequins',
      'category': 'Embellishments',
      'icon': Icons.bubble_chart,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.accessories)),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.8,
        ),
        itemCount: _mockVendors.length,
        itemBuilder: (context, index) {
          final vendor = _mockVendors[index];
          return Card(
            elevation: 2,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Icon(
                      vendor['icon'] as IconData,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    children: [
                      Text(
                        vendor['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vendor['category'] as String,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(AppLocalizations.of(context)!.viewCatalog, style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
