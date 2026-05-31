import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../services/tailor_service.dart';
import '../../routes/app_routes.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class ActiveOrdersScreen extends StatefulWidget {
  const ActiveOrdersScreen({super.key});

  @override
  State<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
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

  @override
  Widget build(BuildContext context) {
    final tailorService = context.watch<TailorService>();
    final activeOrders = tailorService.activeOrders;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: tailorService.isLoading && activeOrders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      final tailorId = context.read<TailorService>().profile?['_id'];
                      if (tailorId != null) {
                        await context.read<TailorService>().fetchTailorOrders(tailorId);
                      }
                    },
                    child: activeOrders.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              Center(child: Text("No active orders")),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: activeOrders.length,
                            itemBuilder: (context, index) {
                              final order = activeOrders[index];
                              return _buildOrderCard(context, order);
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
            AppLocalizations.of(context)!.activeOrders,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final String id = order['_id'] ?? '';
    final String item = order['dressType'] ?? 'Custom Dress';
    final String customerName = order['customerId']?['name'] ?? 'Unknown Customer';
    
    String updatedDateStr = 'Unknown';
    if (order['updatedAt'] != null) {
      try {
        final dt = DateTime.parse(order['updatedAt']).toLocal();
        updatedDateStr = "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour)}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
      } catch (_) {}
    }
    
    final String status = order['status'] ?? 'unknown';

    double progress = 0.5;
    if (status == 'revision-in-progress') progress = 0.8;
    if (status == 'ready') progress = 1.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: id),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ID: #${order['orderNumber'] ?? id.substring(id.length > 6 ? id.length - 6 : 0).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Updated: $updatedDateStr',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(item, style: const TextStyle(fontSize: 16)),
              Text(customerName, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(status.toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
