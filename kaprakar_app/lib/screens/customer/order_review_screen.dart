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
import '../../services/chat_service.dart';
import '../../services/journey_service.dart';
import 'package:provider/provider.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class OrderReviewScreen extends StatefulWidget {
  const OrderReviewScreen({super.key});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  late final String orderId;
  bool _loading = true;
  Map<String, dynamic>? _order;
  String? _error;
  bool _didInit = false;

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
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _messageTailor(String tailorUserId, String tailorName) async {
    final myUserId = JourneyService().currentUserId ?? "";
    final chatService = context.read<ChatService>();
    try {
      final chat = await chatService.accessChat(myUserId, tailorUserId);
      if (!context.mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.chatDetail,
        arguments: {
          'chatId': chat['_id'],
          'otherUserName': tailorName,
          'myUserId': myUserId,
          'otherUserId': tailorUserId,
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error starting chat: $e')));
    }
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: AppRadius.cardRadius,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color c;
    switch (status.toLowerCase()) {
      case 'completed':
        c = AppColors.success;
        break;
      case 'revision-requested':
        c = AppColors.secondary;
        break;
      default:
        c = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        border: Border.all(color: c),
        borderRadius: AppRadius.pillRadius,
      ),
      child: Text(status, style: AppTextStyles.labelSmall.copyWith(color: c)),
    );
  }

  Widget _measureRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            '$value"',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l) {
    final String? finalPhotoUrl = _order?['finalDressImageUrl'] as String?;
    final measurements =
        (_order?['measurements'] as Map<String, dynamic>?) ?? {};
    final String tailorName = _order?['tailorName'] as String? ?? 'Tailor';
    final String shopName = _order?['tailorId']?['shopName'] as String? ?? '';
    final String tailorUserId = _order?['tailorId']?['userId'] as String? ?? '';
    final String status = _order?['status'] as String? ?? 'Pending';
    final String designNotes = _order?['designNotes'] as String? ?? '';
    final bool hasPhoto = finalPhotoUrl != null && finalPhotoUrl.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tailor card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.cardRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    tailorName.isNotEmpty ? tailorName[0].toUpperCase() : 'T',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tailorName, style: AppTextStyles.labelLarge),
                      if (shopName.isNotEmpty)
                        Text(shopName, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l.orderReviewTitle, style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          if (!hasPhoto)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.border.withValues(alpha: 0.3),
                borderRadius: AppRadius.cardRadius,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textSecondary,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l.tailorNotUploadedYet,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton.icon(
                    onPressed: _fetchOrder,
                    icon: const Icon(Icons.refresh, color: AppColors.primary),
                    label: Text(
                      'Refresh',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ClipRRect(
              borderRadius: AppRadius.cardRadius,
              child: Image.network(
                finalPhotoUrl,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 280,
                  color: AppColors.border,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          if (measurements.isNotEmpty) ...[
            Text(l.measurements, style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  if (measurements['chest'] != null)
                    _measureRow('Chest', measurements['chest']),
                  if (measurements['waist'] != null)
                    _measureRow('Waist', measurements['waist']),
                  if (measurements['hips'] != null)
                    _measureRow('Hips', measurements['hips']),
                  if (measurements['shoulder'] != null)
                    _measureRow('Shoulder', measurements['shoulder']),
                  if (measurements['sleeve'] != null)
                    _measureRow('Sleeve', measurements['sleeve']),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (designNotes.isNotEmpty) ...[
            Text('Design Notes', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: AppRadius.cardRadius,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(designNotes, style: AppTextStyles.bodyMedium),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (hasPhoto) ...[
            PrimaryButton(
              text: l.viewOn3DAvatar,
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.avatarPreview,
                arguments: {
                  'orderId': orderId,
                  'dressImageUrl': finalPhotoUrl,
                  'tailorName': tailorName,
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              text: l.requestChangesButton,
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.changeRequest,
                arguments: {'orderId': orderId},
              ),
            ),
          ],
          if (tailorUserId.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              text: "Message Tailor",
              onPressed: () => _messageTailor(tailorUserId, tailorName),
            ),
          ],
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
      appBar: AppBar(title: Text(l.orderReviewTitle), centerTitle: true),
      body: _loading
          ? _buildShimmer()
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
                  Text(_error!, style: AppTextStyles.bodySmall),
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
