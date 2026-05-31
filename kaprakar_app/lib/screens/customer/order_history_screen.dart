import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../services/journey_service.dart';
import '../../services/chat_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String myUserId = context.read<JourneyService>().currentUserId ?? "";
      context.read<JourneyService>().fetchCustomerOrders(myUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final journeyService = context.watch<JourneyService>();
    final orders = journeyService.orderHistory;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: journeyService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.noOrdersYet1))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildOrderCard(context, order);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            AppLocalizations.of(context)!.orderHistory,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    // Parse order fields based on backend schema
    final String rawId = order['_id'].toString();
    final String shortId = order['orderNumber']?.toString() ?? (rawId.length > 6 ? rawId.substring(rawId.length - 6).toUpperCase() : rawId);
    final String title = "${order['dressType'] ?? "Custom Dress"} (#$shortId)";
    // Formatting date safely
    final String date = order['createdAt'] != null 
        ? order['createdAt'].toString().split('T')[0] 
        : "N/A";
    final String status = order['status'] ?? "pending";
    final String price = "PKR ${order['amount'] ?? 0}";

    Color statusColor = Colors.grey;
    if (status == "completed" || status == "ready") statusColor = Colors.green;
    if (status == "accepted" || status == "revision-in-progress") statusColor = Colors.orange;
    if (status == "cancelled") statusColor = Colors.red;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              if (price.isNotEmpty)
                Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == 'pending')
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => _confirmDelete(context, order['_id']),
                tooltip: 'Delete Order',
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        onTap: () {
            showModalBottomSheet(
                context: context, 
                builder: (ctx) {
                    final tailorIdObj = order['tailorId'];
                    String? tailorUserId;
                    String tailorName = "Tailor";
                    
                    if (tailorIdObj is Map) {
                       tailorName = tailorIdObj['shopName'] ?? "Tailor";
                       final uId = tailorIdObj['userId'];
                       if (uId is Map) {
                         tailorUserId = uId['_id'];
                       } else if (uId is String) {
                         tailorUserId = uId.toString();
                       }
                    }

                    return Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        height: 250,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Text("Order ID: #$shortId", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                             const SizedBox(height: AppSpacing.md),
                             Text("Tailor: $tailorName", style: const TextStyle(fontSize: 16)),
                             const SizedBox(height: AppSpacing.xl),
                             if (tailorUserId != null)
                               SizedBox(
                                 width: double.infinity,
                                 child: ElevatedButton.icon(
                                   style: ElevatedButton.styleFrom(
                                     padding: const EdgeInsets.symmetric(vertical: 16),
                                     backgroundColor: AppColors.primary,
                                     foregroundColor: Colors.white,
                                   ),
                                   onPressed: () async {
                                     Navigator.pop(ctx);
                                     final myUserId = context.read<JourneyService>().currentUserId ?? "";
                                     final chatService = context.read<ChatService>();
                                     try {
                                       final chat = await chatService.accessChat(myUserId, tailorUserId!);
                                       if (!context.mounted) return;
                                       Navigator.pushNamed(context, '/chat_detail', arguments: {
                                          'chatId': chat['_id'],
                                          'myUserId': myUserId,
                                          'otherUserId': tailorUserId!,
                                          'otherUserName': tailorName,
                                       });
                                     } catch (e) {
                                       if (!context.mounted) return;
                                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error starting chat: $e')));
                                     }
                                   },
                                   icon: const Icon(Icons.chat_bubble_outline),
                                   label: const Text("Message Tailor"),
                                 ),
                               )
                             else
                               const Text("Tailor information unavailable", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                    );
                }
            );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Order"),
        content: const Text("Are you sure you want to delete this order? This action cannot be undone."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<JourneyService>().deleteCustomerOrder(orderId);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Order deleted successfully")),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete order: $e")),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
