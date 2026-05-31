import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../routes/app_routes.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';
import '../../repositories/order_repository.dart';
import 'package:provider/provider.dart';
import '../../services/tailor_service.dart';

class OrderStatusUpdaterScreen extends StatefulWidget {
  const OrderStatusUpdaterScreen({super.key});

  @override
  State<OrderStatusUpdaterScreen> createState() => _OrderStatusUpdaterScreenState();
}

class _OrderStatusUpdaterScreenState extends State<OrderStatusUpdaterScreen> {
  Map<String, dynamic>? _order;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _steps = [
    {
      'status': 'accepted',
      'title': 'Order Accepted',
      'desc': 'You have accepted the order.',
      'icon': Icons.check_circle_outline,
    },
    {
      'status': 'fabric-received',
      'title': 'Fabric Received',
      'desc': 'You have received the fabric.',
      'icon': Icons.shopping_bag_outlined,
    },
    {
      'status': 'in-progress',
      'title': 'Stitching In Progress',
      'desc': 'The dress is currently being stitched.',
      'icon': Icons.cut_outlined,
    },
    {
      'status': 'pending_customer_review',
      'title': 'Upload Stitched Dress on Model',
      'desc': 'Upload final photo for customer review.',
      'icon': Icons.camera_alt_outlined,
    },
    {
      'status': 'completed',
      'title': 'Deliver Order',
      'desc': 'Customer approved. Mark as delivered.',
      'icon': Icons.local_shipping_outlined,
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_order == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _order = args;
      }
    }
  }

  Future<void> _updateStatus(String newStatus, int index) async {
    if (_order == null) return;
    
    if (newStatus == 'pending_customer_review') {
      Navigator.pushNamed(context, AppRoutes.finalPhotoUpload, arguments: {'orderId': _order!['_id']});
      return;
    }

    setState(() => _isLoading = true);
    try {
      final orderRepo = ApiOrderRepository();
      await orderRepo.updateOrderStatus(_order!['_id'], newStatus);
      
      setState(() {
        _order!['status'] = newStatus;
      });
      if (mounted) {
        final tailorService = context.read<TailorService>();
        final orderIndex = tailorService.orders.indexWhere((o) => o['_id'] == _order!['_id']);
        if (orderIndex >= 0) {
          tailorService.orders[orderIndex]['status'] = newStatus;
          tailorService.notifyListeners(); 
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to ${_steps[index]['title']}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.updateStatus)),
        body: const Center(child: Text("Error: Order not found")),
      );
    }

    final currentStatus = _order!['status'] as String? ?? 'pending';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      final step = _steps[index];

                      bool isCompleted = false;
                      bool isNextAvailable = false;
                      String customActionText = 'Update';
                      VoidCallback? onAction = () => _updateStatus(step['status'], index);

                      if (index == 0) {
                        isCompleted = currentStatus != 'pending';
                        isNextAvailable = currentStatus == 'pending';
                      } else if (index == 1) {
                        isCompleted = ['fabric-received', 'in-progress', 'pending_customer_review', 'ready', 'completed', 'revision-requested', 'revision-in-progress'].contains(currentStatus);
                        isNextAvailable = currentStatus == 'accepted';
                      } else if (index == 2) {
                        isCompleted = ['in-progress', 'pending_customer_review', 'ready', 'completed', 'revision-requested', 'revision-in-progress'].contains(currentStatus);
                        isNextAvailable = currentStatus == 'fabric-received';
                      } else if (index == 3) {
                        isCompleted = ['pending_customer_review', 'ready', 'completed', 'revision-requested', 'revision-in-progress'].contains(currentStatus);
                        isNextAvailable = ['in-progress', 'revision-in-progress', 'revision-requested', 'pending_customer_review'].contains(currentStatus);
                        
                        if (currentStatus == 'revision-requested') {
                           customActionText = 'Start Revision';
                           onAction = () => _updateStatus('revision-in-progress', index);
                        } else if (currentStatus == 'revision-in-progress') {
                           customActionText = 'Upload Revision Photo';
                           onAction = () => Navigator.pushNamed(context, AppRoutes.finalPhotoUpload, arguments: {'orderId': _order!['_id']});
                        } else if (currentStatus == 'pending_customer_review') {
                           customActionText = 'Waiting for Customer...';
                           onAction = null; 
                        }
                      } else if (index == 4) {
                        isCompleted = currentStatus == 'completed';
                        isNextAvailable = currentStatus == 'ready';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        elevation: isNextAvailable && onAction != null ? 4 : 0,
                        shadowColor: AppColors.primary.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: isCompleted ? AppColors.primary : (isNextAvailable && onAction != null ? AppColors.primary : AppColors.border),
                            width: isCompleted || (isNextAvailable && onAction != null) ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(AppSpacing.md),
                          leading: CircleAvatar(
                            backgroundColor: isCompleted ? AppColors.primary : (isNextAvailable && onAction != null ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
                            child: Icon(
                              isCompleted && index != 3 ? Icons.check : step['icon'],
                              color: isCompleted ? Colors.white : (isNextAvailable && onAction != null ? AppColors.primary : Colors.grey),
                            ),
                          ),
                          title: Text(
                            step['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCompleted || (isNextAvailable && onAction != null) ? AppColors.textPrimary : Colors.grey,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              index == 3 && currentStatus == 'revision-requested' ? 'Customer requested a revision!' : step['desc'],
                              style: TextStyle(color: isCompleted || (isNextAvailable && onAction != null) ? AppColors.textSecondary : Colors.grey),
                            ),
                          ),
                          trailing: isNextAvailable
                              ? ElevatedButton(
                                  onPressed: onAction,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: onAction == null ? Colors.grey : AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(customActionText),
                                )
                              : null,
                        ),
                      );
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
            AppLocalizations.of(context)!.updateStatus,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
