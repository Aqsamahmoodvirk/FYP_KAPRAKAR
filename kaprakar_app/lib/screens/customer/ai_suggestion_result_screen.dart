import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_radius.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../routes/app_routes.dart';
import '../../services/journey_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class AISuggestionResultScreen extends StatefulWidget {
  const AISuggestionResultScreen({super.key});

  @override
  State<AISuggestionResultScreen> createState() => _AISuggestionResultScreenState();
}

class _AISuggestionResultScreenState extends State<AISuggestionResultScreen> {
  List<Map<String, dynamic>> _suggestions = [];
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is List<Map<String, dynamic>>) {
        _suggestions = args;
      } else if (args is List) {
        _suggestions = args.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    }
  }

  Color? _parseColor(String colorStr) {
    try {
      final sanitized = colorStr.trim();
      if (sanitized.startsWith('#')) {
        final hex = sanitized.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      }
      switch (sanitized.toLowerCase()) {
        case 'black': return Colors.black;
        case 'white': return Colors.white;
        case 'red': return Colors.red;
        case 'blue': return Colors.blue;
        case 'green': return Colors.green;
        case 'pink': return Colors.pink;
        case 'yellow': return Colors.yellow;
        case 'teal': return const Color(0xFF006D77);
        case 'peach': return const Color(0xFFE29578);
        case 'gold': return const Color(0xFFD4AF37);
        case 'maroon': return const Color(0xFF800000);
      }
    } catch (e) {
      debugPrint("Color parsing error for $colorStr: $e");
    }
    return null;
  }

  Future<void> _openInspirationLink(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not open link in browser.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Link opening error: $e");
    }
  }

  Widget _buildEmptyState(AppLocalizations l) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.style_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l.noStylesFound,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We couldn\'t find any suggestions for your selected fabric option. Try choosing a different color or occasion combination.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            SecondaryButton(
              text: l.tryDifferentOptions,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccasionBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildSeasonBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (_suggestions.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l.aiResultTitle),
          centerTitle: true,
        ),
        body: _buildEmptyState(l),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l.aiResultTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header showing number of styles found
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF00838F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.cardRadius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.white,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_suggestions.length} Styles Found',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'AI-recommended styles perfect for your fabric',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // List of suggestions
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                
                // Extract values with flexible fallbacks
                final String styleName = item['styleName'] ?? item['style'] ?? 'Modern Shalwar Kameez';
                final String occasion = item['occasion'] ?? 'Casual';
                final String season = item['season'] ?? 'Summer';
                final String sleeveType = item['sleeveType'] ?? item['sleeve'] ?? 'Full Sleeves';
                final String neckStyle = item['neckStyle'] ?? item['neck'] ?? 'V-Neck';
                final String embroideryType = item['embroideryType'] ?? item['embroidery'] ?? 'Subtle Threadwork';
                final String inspoLink = item['inspoLink'] ?? 'https://pinterest.com';

                final dynamic colorsData = item['colorChips'] ?? item['colors'] ?? ['#006D77'];
                final List<String> colorsList = colorsData is List 
                    ? colorsData.map((e) => e.toString()).toList() 
                    : [colorsData.toString()];

                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.cardRadius,
                      side: BorderSide(color: AppColors.border, width: 1),
                    ),
                    elevation: 3,
                    shadowColor: AppColors.textSecondary.withValues(alpha: 0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Style Name & Badges
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  styleName,
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    fontSize: 18,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          // Badges row
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              _buildOccasionBadge(occasion),
                              _buildSeasonBadge(season),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: AppSpacing.sm),
                          
                          // Style specifications
                          _buildDetailRow(Icons.checkroom, 'Sleeve Type', sleeveType),
                          _buildDetailRow(Icons.rounded_corner, 'Neck Style', neckStyle),
                          _buildDetailRow(Icons.brush, 'Embroidery', embroideryType),
                          
                          const SizedBox(height: AppSpacing.sm),
                          // Color Chips section
                          Text(
                            'Colors:',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: colorsList.map((c) {
                              final parsedColor = _parseColor(c);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs - 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.border.withValues(alpha: 0.3),
                                  borderRadius: AppRadius.pillRadius,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (parsedColor != null) ...[
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: parsedColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: parsedColor == Colors.white 
                                                ? AppColors.textSecondary 
                                                : Colors.transparent,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      c,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        fontSize: 11,
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          
                          // Inspiration Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Style Inspo:',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => _openInspirationLink(inspoLink),
                                icon: const Icon(
                                  Icons.open_in_new,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                label: Text(
                                  l.viewInspiration,
                                  style: AppTextStyles.linkText.copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          
                          // Select Button
                          PrimaryButton(
                            text: l.selectStyle,
                            onPressed: () {
                              final service = JourneyService();
                              service.setSelectedAiStyle(item);
                              service.completeAiSuggestions();
                              
                              Navigator.pushNamed(
                                context, 
                                AppRoutes.findTailor,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
