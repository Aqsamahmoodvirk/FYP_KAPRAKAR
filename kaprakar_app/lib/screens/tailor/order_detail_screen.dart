import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../services/tailor_service.dart';
import '../../services/chat_service.dart';
import '../../services/journey_service.dart';
import '../../routes/app_routes.dart';
import '../../repositories/order_repository.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  Future<void> _messageCustomer(
    BuildContext context,
    String customerId,
    String customerName,
  ) async {
    final myUserId = JourneyService().currentUserId ?? "";
    final chatService = context.read<ChatService>();
    try {
      final chat = await chatService.accessChat(myUserId, customerId);
      if (!context.mounted) return;

      final participants = chat['participants'] as List<dynamic>? ?? [];
      final otherUser = participants.firstWhere(
        (p) => p['_id'] == customerId,
        orElse: () => {'name': customerName},
      );
      final String realName = otherUser['name'] ?? customerName;

      Navigator.pushNamed(
        context,
        AppRoutes.chatDetail,
        arguments: {
          'chatId': chat['_id'],
          'otherUserName': realName,
          'myUserId': myUserId,
          'otherUserId': customerId,
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error starting chat: $e')));
    }
  }

  Future<void> _updateOrderStatus(
    BuildContext context,
    Map<String, dynamic> order,
    String newStatus,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
    try {
      final repo = ApiOrderRepository();
      await repo.updateOrderStatus(order['_id'], newStatus);
      if (!context.mounted) return;
      Navigator.pop(context); // Close dialog

      final tailorService = context.read<TailorService>();
      final orderIndex = tailorService.orders.indexWhere(
        (o) => o['_id'] == order['_id'],
      );
      if (orderIndex >= 0) {
        tailorService.orders[orderIndex]['status'] = newStatus;
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        tailorService.notifyListeners();
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order $newStatus successfully')));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildNextStepGuide(String status) {
    String guideText = '';
    IconData guideIcon = Icons.info_outline;
    Color guideColor = AppColors.primary;

    switch (status) {
      case 'pending':
        guideText =
            "Next Step: Review the details below. If you can fulfill this request, Accept the order to begin.";
        guideIcon = Icons.help_outline;
        guideColor = Colors.amber.shade700;
        break;
      case 'accepted':
        guideText =
            "Next Step: Wait for the customer to provide fabric, or begin stitching if you already have what you need.";
        guideIcon = Icons.shopping_bag_outlined;
        guideColor = AppColors.secondary;
        break;
      case 'fabric-received':
        guideText =
            "Next Step: You have the fabric! Begin the stitching process.";
        guideIcon = Icons.cut_outlined;
        guideColor = AppColors.primary;
        break;
      case 'in-progress':
        guideText =
            "Next Step: Finish stitching and upload a photo of the final dress on a mannequin for customer review.";
        guideIcon = Icons.camera_alt_outlined;
        guideColor = AppColors.accentGold;
        break;
      case 'pending_customer_review':
        guideText =
            "Next Step: Wait for the customer to approve the final photos or request revisions.";
        guideIcon = Icons.hourglass_top;
        guideColor = Colors.deepOrange;
        break;
      case 'completed':
        guideText =
            "Next Step: The order is complete! Deliver the dress to the customer.";
        guideIcon = Icons.local_shipping_outlined;
        guideColor = AppColors.success;
        break;
      case 'cancelled':
        guideText = "This order has been cancelled.";
        guideIcon = Icons.cancel_outlined;
        guideColor = AppColors.error;
        break;
      default:
        guideText = "Next Step: Proceed with the next phase of the order.";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: guideColor.withValues(alpha: 0.1),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: guideColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(guideIcon, color: guideColor, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              guideText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: guideColor,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderId = ModalRoute.of(context)?.settings.arguments as String?;
    final tailorService = context.watch<TailorService>();
    final order = tailorService.orders.firstWhere(
      (o) => o['_id'] == orderId,
      orElse: () => {},
    );

    if (order.isEmpty) {
      return Scaffold(appBar: AppBar(title: const Text("Order Not Found")));
    }

    final String status = order['status'] ?? 'pending';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context, order),
          Expanded(
            child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Next Step Guide
            _buildNextStepGuide(status),

            // Order Info Header
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: AppRadius.cardRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order['dressType'] ?? 'Custom Dress',
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Customer: ${order['customerId']?['name'] ?? 'Unknown'}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Due Date: ${order['expectedDeliveryDate']?.toString().split('T')[0] ?? 'N/A'}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'PKR ${order['amount'] ?? 0}',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Actions
            if (status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _updateOrderStatus(context, order, 'cancelled'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Decline",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _updateOrderStatus(context, order, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Accept Order",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final customerId = order['customerId']?['_id'] ?? '';
                        final customerName =
                            order['customerId']?['name'] ?? 'Customer';
                        if (customerId.isNotEmpty) {
                          _messageCustomer(context, customerId, customerName);
                        }
                      },
                      icon: const Icon(Icons.message),
                      label: const Text("Message"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.orderStatusUpdater,
                        arguments: order,
                      ),
                      icon: const Icon(Icons.update),
                      label: Text(AppLocalizations.of(context)!.updateStatus),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.xl),

            // Measurements
            Text(
              AppLocalizations.of(context)!.measurements,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child:
                  (order['measurementId'] != null &&
                      (order['measurementId'] as Map).isNotEmpty)
                  ? Column(
                      children: (order['measurementId'] as Map<String, dynamic>)
                          .entries
                          .where(
                            (e) =>
                                ![
                                  '_id',
                                  '__v',
                                  'userId',
                                  'createdAt',
                                  'updatedAt',
                                  'notes',
                                ].contains(e.key) &&
                                e.value != null,
                          )
                          .map((e) {
                            final String keyName = e.key.isNotEmpty
                                ? '${e.key[0].toUpperCase()}${e.key.substring(1)}'
                                : e.key;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    keyName,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    e.value.toString(),
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                          .toList(),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Text(
                          "No measurements provided",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Fabric & Design
            Text(
              AppLocalizations.of(context)!.fabricDesignNotes,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order['suggestedImageUrl'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inspiration',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final String imageUrl = order['suggestedImageUrl']!.startsWith('http')
                                ? order['suggestedImageUrl']!
                                : 'http://172.23.181.1:5000${order['suggestedImageUrl']!}';
                            
                            final Uri url = Uri.parse(imageUrl);
                            if (imageUrl.startsWith('http') && !imageUrl.contains('172.23.181.1')) {
                               // It's likely an external link, try to launch it directly
                               if (await canLaunchUrl(url)) {
                                 await launchUrl(url, mode: LaunchMode.externalApplication);
                                 return;
                               }
                            }

                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: EdgeInsets.zero,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    InteractiveViewer(
                                      panEnabled: true,
                                      minScale: 0.5,
                                      maxScale: 4.0,
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (context, error, stackTrace) => Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.link, color: Colors.white, size: 40),
                                              const SizedBox(height: 16),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  if (await canLaunchUrl(url)) {
                                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                                  }
                                                },
                                                child: const Text('Open Link'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 40,
                                      right: 20,
                                      child: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 300,
                                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    order['suggestedImageUrl']!.startsWith('http')
                                        ? order['suggestedImageUrl']!
                                        : 'http://172.23.181.1:5000${order['suggestedImageUrl']!}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.link, size: 40, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tap to open external link',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 24, // Account for bottom margin
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.open_in_new, color: Colors.white, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order['notes']?.toString().isNotEmpty == true
                          ? order['notes']
                          : 'No special notes or design instructions provided by the customer.',
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> order) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: AppSpacing.sm, 
        right: AppSpacing.lg, 
        top: MediaQuery.of(context).padding.top + AppSpacing.sm, 
        bottom: AppSpacing.xl
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF004D54)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            order['_id'] != null
                ? "Order #${order['orderNumber'] ?? order['_id'].substring(order['_id'].length > 6 ? order['_id'].length - 6 : 0).toUpperCase()}"
                : "Order Details",
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
