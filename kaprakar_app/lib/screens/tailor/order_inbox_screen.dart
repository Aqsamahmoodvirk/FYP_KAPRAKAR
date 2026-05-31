import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../services/tailor_service.dart';
import '../../repositories/order_repository.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class OrderInboxScreen extends StatefulWidget {
  const OrderInboxScreen({super.key});

  @override
  State<OrderInboxScreen> createState() => _OrderInboxScreenState();
}

class _OrderInboxScreenState extends State<OrderInboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tailorId = context.read<TailorService>().profile?['_id'];
      if (tailorId != null) {
        context.read<TailorService>().fetchTailorOrders(tailorId);
      }
    });
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      await context.read<OrderRepository>().updateOrderStatus(orderId, newStatus);
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order $newStatus successfully')),
      );
      
      // Refresh the orders
      final tailorId = context.read<TailorService>().profile?['_id'];
      if (tailorId != null) {
        context.read<TailorService>().fetchTailorOrders(tailorId);
      }
    } catch (e) {
      if (!mounted) return;
      // Close loading dialog
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tailorService = context.watch<TailorService>();
    final pendingOrders = tailorService.pendingOrders;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: tailorService.isLoading && pendingOrders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      final tailorId = context.read<TailorService>().profile?['_id'];
                      if (tailorId != null) {
                        await context.read<TailorService>().fetchTailorOrders(tailorId);
                      }
                    },
                    child: pendingOrders.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              Center(child: Text("No new requests")),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: pendingOrders.length,
                            itemBuilder: (context, index) {
                              final request = pendingOrders[index];
                              return _buildInboxCard(context, request);
                            },
                          ),
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
            AppLocalizations.of(context)!.inboxRequests,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInboxCard(BuildContext context, Map<String, dynamic> request) {
    final String id = request['_id'] ?? '';
    final String status = request['status'] ?? 'pending';
    final String item = request['dressType'] ?? 'Custom Dress';
    final String customerName = request['customerId']?['name'] ?? 'Unknown Customer';
    
    String orderedDateStr = 'Unknown';
    if (request['createdAt'] != null) {
      try {
        final dt = DateTime.parse(request['createdAt']).toLocal();
        orderedDateStr = "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour)}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
      } catch (_) {}
    }
    
    final String price = "PKR ${request['amount'] ?? 0}";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ID: #${request['orderNumber'] ?? id.substring(id.length > 6 ? id.length - 6 : 0).toUpperCase()}",
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(status.toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(item, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(customerName, style: const TextStyle(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text("Ordered: $orderedDateStr",
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                Text(price,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateOrderStatus(id, 'cancelled'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red)),
                    child: Text(AppLocalizations.of(context)!.decline),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(id, 'accepted'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: Text(AppLocalizations.of(context)!.reviewAccept),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
