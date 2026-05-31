import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/feature_card.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen lists tailoring categories users can book
    final categories = [
      {'title': 'Shalwar Kameez', 'icon': Icons.checkroom},
      {'title': 'Kurta', 'icon': Icons.accessibility_new},
      {'title': 'Lehenga', 'icon': Icons.female},
      {'title': 'Sherwani', 'icon': Icons.male},
      {'title': 'Alteration', 'icon': Icons.cut},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.bookAService),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return FeatureCard(
                    title: categories[index]['title'] as String,
                    icon: categories[index]['icon'] as IconData,
                    onTap: () {
                      // Navigate to specific booking detail or tailor selection
                      // For now, consistent with flow, might go to Find Tailor
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
