import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_radius.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../routes/app_routes.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class RevisionInboxScreen extends StatefulWidget {
  const RevisionInboxScreen({super.key});

  @override
  State<RevisionInboxScreen> createState() => _RevisionInboxScreenState();
}

class _RevisionInboxScreenState extends State<RevisionInboxScreen> {
  late final String orderId;
  bool _didInit = false;
  bool _loading = true;
  Map<String, dynamic>? _order;
  String? _error;
  bool _photoFullScreen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      orderId = args?['orderId'] as String? ?? '';
      _fetchOrder();
    }
  }

  Future<void> _fetchOrder() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      final response = await http.get(
        Uri.parse('http://172.23.181.1:5000/api/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _order = jsonDecode(response.body) as Map<String, dynamic>;
          _loading = false;
        });
      } else {
        throw Exception('Server error ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _buildCategoryBadge(String category) {
    final Map<String, Color> colors = {
      'Fitting Issue': const Color(0xFFE29578),
      'Length Issue': const Color(0xFFD4AF37),
      'Embroidery Issue': const Color(0xFF8B5CF6),
      'Style Change': const Color(0xFF006D77),
      'Other': const Color(0xFF6B7280),
    };
    final Color badgeColor = colors[category] ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        border: Border.all(color: badgeColor),
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(
        category,
        style: AppTextStyles.labelSmall.copyWith(color: badgeColor),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l) {
    final String customerName =
        _order?['customerName'] as String? ?? 'Customer';
    final String? customerPhoto = _order?['customerPhotoUrl'] as String?;
    final String revisionNote = _order?['revisionNote'] as String? ?? '';
    final String revisionCategory =
        _order?['revisionCategory'] as String? ?? 'Other';
    final String? revisionImageUrl = _order?['revisionImageUrl'] as String?;
    final String? tailorDressPhotoUrl =
        _order?['finalDressImageUrl'] as String?;
    final measurements =
        (_order?['measurements'] as Map<String, dynamic>?) ?? {};
    final String dressType = _order?['dressType'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.cardRadius,
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                  backgroundImage:
                      customerPhoto != null && customerPhoto.isNotEmpty
                      ? NetworkImage(customerPhoto)
                      : null,
                  child: customerPhoto == null || customerPhoto.isEmpty
                      ? Text(
                          customerName.isNotEmpty
                              ? customerName[0].toUpperCase()
                              : 'C',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.secondary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customerName, style: AppTextStyles.labelLarge),
                      if (dressType.isNotEmpty)
                        Text(
                          'Order: $dressType',
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                  ),
                ),
                _buildCategoryBadge(revisionCategory),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Original measurements
          if (measurements.isNotEmpty) ...[
            Text('Original Measurements', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(color: AppColors.border),
              ),
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                children: measurements.entries
                    .map(
                      (e) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${e.key}: ', style: AppTextStyles.bodySmall),
                          Text(
                            '${e.value}"',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Revision note
          Text('Customer\'s Revision Note', style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: AppRadius.cardRadius,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: revisionNote.isNotEmpty
                ? Text(revisionNote, style: AppTextStyles.bodyMedium)
                : Text('No note provided', style: AppTextStyles.bodySmall),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Customer reference photo
          if (revisionImageUrl != null && revisionImageUrl.isNotEmpty) ...[
            Text(
              'Customer\'s Reference Photo',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => setState(() => _photoFullScreen = !_photoFullScreen),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _photoFullScreen ? 340 : 180,
                width: double.infinity,
                decoration: BoxDecoration(borderRadius: AppRadius.cardRadius),
                child: ClipRRect(
                  borderRadius: AppRadius.cardRadius,
                  child: Image.network(
                    revisionImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.border,
                      child: const Icon(
                        Icons.broken_image,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    setState(() => _photoFullScreen = !_photoFullScreen),
                icon: Icon(
                  _photoFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: Text(
                  _photoFullScreen ? 'Collapse' : 'Full View',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Tailor's previously uploaded dress
          if (tailorDressPhotoUrl != null &&
              tailorDressPhotoUrl.isNotEmpty) ...[
            Text(
              'Your Previously Uploaded Dress',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: AppRadius.cardRadius,
              child: Image.network(
                tailorDressPhotoUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: AppColors.border,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            text: l.uploadRevisedPhoto,
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.finalPhotoUpload,
              arguments: {'orderId': orderId, 'isRevision': true},
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            text: 'Message Customer',
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.chatDetail,
              arguments: {
                'id': orderId,
                'tailorName': customerName,
                'isOnline': false,
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(l.revisionInboxTitle), centerTitle: true),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _error!,
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: _fetchOrder,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _buildContent(l),
    );
  }
}
