import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../services/journey_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class RequestHistoryScreen extends StatefulWidget {
  const RequestHistoryScreen({super.key});

  @override
  State<RequestHistoryScreen> createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends State<RequestHistoryScreen> {
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
    final history = journeyService.orderHistory;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.requestHistory)),
      body: journeyService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.noHistoryYet))
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: history.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return _buildHistoryCard(context, item);
                  },
                ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> item) {
    final String title = item['dressType'] ?? "Custom Request";
    final String date = item['createdAt'] != null 
        ? item['createdAt'].toString().split('T')[0] 
        : "N/A";
    final String status = item['status'] ?? "pending";
    final String price = "PKR ${item['amount'] ?? 0}";

    Color statusColor = Colors.grey;
    if (status == "completed" || status == "ready") statusColor = Colors.green;
    if (status == "accepted" || status == "revision-in-progress") statusColor = Colors.orange;
    if (status == "cancelled") statusColor = Colors.red;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: () {
           // Placeholder for detail navigation
        },
      ),
    );
  }
}
