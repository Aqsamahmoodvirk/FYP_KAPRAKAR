import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../services/journey_service.dart';
import '../../repositories/order_repository.dart';
import '../../services/auth_service.dart'; // To get baseUrl for image
import 'package:kaprakar_app/l10n/app_localizations.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'preview_3d_screen.dart';
import '../../routes/app_routes.dart';

enum PaymentState { idle, authenticating, success }

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  bool _isLoading = true;
  String _currentStatus = 'pending';
  String? _orderId;
  Map<String, dynamic>? _orderData;
  bool _hasShownRatingDialog = false;
  PaymentState _paymentState = PaymentState.idle;
  Timer? _pollingTimer;
  Timer? _paymentPollingTimer;

  final List<Map<String, dynamic>> _timelineSteps = [
    {'status': 'accepted', 'title': 'Order Placed', 'icon': Icons.receipt_long},
    {'status': 'fabric-received', 'title': 'Fabric Received', 'icon': Icons.shopping_bag_outlined},
    {'status': 'in-progress', 'title': 'Stitching In Progress', 'icon': Icons.cut_outlined},
    {'status': 'pending_customer_review', 'title': 'Preview Model', 'icon': Icons.camera_alt_outlined},
    {'status': 'pending_payment', 'title': 'Payment Required', 'icon': Icons.payment},
    {'status': 'ready', 'title': 'Out for Delivery', 'icon': Icons.local_shipping_outlined},
    {'status': 'completed', 'title': 'Received', 'icon': Icons.check_circle_outline},
  ];

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      if (_currentStatus == 'pending_customer_review' && (_orderData == null || _orderData!['finalDressModelUrl'] == null)) {
        _fetchOrder(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _paymentPollingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_orderId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _orderId = args;
      } else if (args is Map) {
        _orderId = args['orderId']?.toString();
      }
      _orderId ??= JourneyService().activeOrderId;
      _fetchOrder();
    }
  }

  Future<void> _fetchOrder({bool silent = false}) async {
    final service = JourneyService();
    if (_orderId == null) {
      if (!silent && mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final repo = ApiOrderRepository();
      final orders = await repo.getCustomerOrders(service.currentUserId!);
      final order = orders.firstWhere((o) => o['_id'] == _orderId, orElse: () => {});
      
      if (order.isNotEmpty && mounted) {
        setState(() {
          _orderData = order;
          _currentStatus = order['status'] ?? 'pending';
        });

        if (_currentStatus == 'completed' && _orderData!['feedbackRating'] == null && !_hasShownRatingDialog) {
          _hasShownRatingDialog = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showRatingDialog();
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch order status: $e");
    } finally {
      if (!silent && mounted) setState(() => _isLoading = false);
    }
  }

  int _getCurrentStepIndex() {
    if (_currentStatus == 'revision-requested' || _currentStatus == 'revision-in-progress') return 3; 
    final index = _timelineSteps.indexWhere((step) => step['status'] == _currentStatus);
    return index >= 0 ? index : -1;
  }

  Future<void> _markAsReceived() async {
    setState(() => _isLoading = true);
    try {
      final repo = ApiOrderRepository();
      await repo.updateOrderStatus(_orderId!, 'completed');
      await _fetchOrder();
      // The pop-up rating logic will trigger automatically since status is now 'completed'
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptPreview() async {
    setState(() => _isLoading = true);
    try {
      final repo = ApiOrderRepository();
      await repo.updateOrderStatus(_orderId!, 'pending_payment');
      await _fetchOrder();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preview Accepted! Please complete the payment.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      setState(() => _isLoading = false);
    }
  }

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text("Safepay Secure Checkout", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              const Text("You will be redirected to Safepay's secure checkout environment to complete your payment.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _handlePayment();
                  },
                  icon: const Icon(Icons.lock_outline),
                  label: const Text("Pay with Safepay (Test Mode)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  Future<void> _handlePayment() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() => _paymentState = PaymentState.authenticating);
    final service = JourneyService();
    final amount = double.tryParse(_orderData?['totalPrice']?.toString() ?? '1500') ?? 1500.0;
    
    final checkoutUrl = await service.generateCheckout(_orderId!, amount, service.currentUserId ?? '');
    
    if (checkoutUrl != null && mounted) {
      final url = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(url)) {
        // Test in external browser to bypass Android WebView tracking/DOM storage restrictions
        await launchUrl(url, mode: LaunchMode.externalApplication);
        
        // Start 3-second polling for payment status
        _paymentPollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
          if (!mounted) {
            timer.cancel();
            return;
          }
          final status = await service.getPaymentStatus(_orderId!);
          if (status == 'paid') {
            timer.cancel();
            await _fetchOrder(); // Will fetch the updated order where status = 'ready'
            if (mounted) {
              closeInAppWebView();
              setState(() => _paymentState = PaymentState.success);
              
              // Clear cart (if applicable) and return to home after 2s
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.customerHome);
                }
              });
            }
          } else if (status == 'cancelled') {
            // Automatically close the WebView when backend detects cancellation
            timer.cancel();
            closeInAppWebView();
            if (mounted) {
              setState(() => _paymentState = PaymentState.idle);
              scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Payment Cancelled. You can try again later.')));
            }
          }
        });
      } else {
        setState(() => _paymentState = PaymentState.idle);
        if (mounted) scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Could not launch Safepay Checkout.')));
      }
    } else {
      setState(() => _paymentState = PaymentState.idle);
      if (mounted) scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Failed to generate checkout link.')));
    }
  }

  Future<void> _cancelPayment() async {
    if (_paymentPollingTimer != null && _paymentPollingTimer!.isActive) {
      _paymentPollingTimer!.cancel();
    }
    setState(() => _paymentState = PaymentState.idle);
    closeInAppWebView();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Cancelled. You can try again later.')));
      // Removed the navigation and order cancellation so the order safely remains 'unpaid'
    }
  }

  void _showRejectDialog() {
    String note = '';
    String category = 'Fitting Issue';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Request Revision", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    value: category,
                    items: ['Fitting Issue', 'Length Issue', 'Embroidery Issue', 'Style Change', 'Other']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setModalState(() => category = val!),
                    decoration: const InputDecoration(labelText: "Issue Category"),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    decoration: const InputDecoration(labelText: "Details", border: OutlineInputBorder()),
                    maxLines: 3,
                    onChanged: (val) => note = val,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() => _isLoading = true);
                        try {
                           final repo = ApiOrderRepository();
                           await repo.updateOrderStatus(_orderId!, 'revision-requested');
                           await _fetchOrder();
                           if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Revision Requested sent to tailor.')));
                        } catch (e) {
                           if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                           setState(() => _isLoading = false);
                        }
                      },
                      child: const Text("Submit Revision Request"),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showRatingDialog() {
    int _rating = 5;
    String _comment = '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.xl,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const Text("Rate Your Tailor!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.sm),
                  const Text("How was your experience with this order?", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          size: 40,
                          color: Colors.amber,
                        ),
                        onPressed: () => setModalState(() => _rating = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Leave a comment (optional)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                    ),
                    maxLines: 3,
                    onChanged: (val) => _comment = val,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() => _isLoading = true);
                        try {
                          final repo = ApiOrderRepository();
                          await repo.submitFeedback(_orderId!, _rating, _comment);
                          await _fetchOrder();
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your feedback!')));
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                          setState(() => _isLoading = false);
                        }
                      },
                      child: const Text("Submit Review", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_paymentState == PaymentState.success) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: const Icon(Icons.check_circle, color: Colors.green, size: 100),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text("Payment Successful!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text("Your tailor has been notified.", style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    if (_paymentState == PaymentState.authenticating) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
                const SizedBox(height: 32),
                const Text("Waiting for payment confirmation...", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                const Text("Please do not close this window.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 48),
                TextButton.icon(
                  onPressed: _cancelPayment,
                  icon: const Icon(Icons.cancel, color: AppColors.error),
                  label: const Text("Cancel Payment", style: TextStyle(color: AppColors.error, fontSize: 16)),
                )
              ],
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.trackOrder)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_orderId == null || _orderData == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.trackOrder)),
        body: Center(child: Text(AppLocalizations.of(context)!.noActiveOrderFound)),
      );
    }

    final currentIndex = _getCurrentStepIndex();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchOrder,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order Tracking", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    _orderData != null 
                        ? "${_orderData!['dressType'] ?? 'Custom Dress'} (#${_orderData!['orderNumber'] ?? (_orderId!.length > 6 ? _orderId!.substring(_orderId!.length - 6).toUpperCase() : _orderId!)})" 
                        : "#${_orderId!.length > 6 ? _orderId!.substring(_orderId!.length - 6).toUpperCase() : _orderId!}", 
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            ...List.generate(_timelineSteps.length, (index) {
              final step = _timelineSteps[index];
              final isCompleted = index <= currentIndex;
              final isCurrent = index == currentIndex || (currentIndex == -1 && index == 0 && _currentStatus == 'pending');
              final isLast = index == _timelineSteps.length - 1;

              Widget? customContent;
              
              if (index == 3 && currentIndex >= 3 && _orderData!['finalDressImageUrl'] != null) {
                final dbPath = _orderData!['finalDressImageUrl'].toString();
                final filename = dbPath.split(RegExp(r'[\\/]')).last;
                final imageUrl = '${AuthService.baseUrl}/uploads/$filename';
                final modelUrlPath = _orderData!['finalDressModelUrl'];
                
                customContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (modelUrlPath != null)
                      ElevatedButton.icon(
                        onPressed: () {
                          final mUrl = '${AuthService.baseUrl}$modelUrlPath';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Preview3DScreen(modelUrl: mUrl),
                            ),
                          );
                        },
                        icon: const Icon(Icons.threed_rotation),
                        label: const Text("View 3D Model"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: Text("3D Model generation in progress... (May take ~5 mins)", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                    if (_currentStatus == 'pending_customer_review') ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                              onPressed: _showRejectDialog,
                              child: const Text("Reject"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                              onPressed: _acceptPreview,
                              child: const Text("Accept"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              } else if (index == 4 && _currentStatus == 'pending_payment') {
                customContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text("Please proceed to secure checkout to initiate your order.", style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _showPaymentModal,
                        icon: const Icon(Icons.lock_outline),
                        label: const Text("Initiate Payment", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                );
              } else if (index == 5 && _currentStatus == 'ready') {
                customContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text("Your dress is out for delivery!", style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _markAsReceived,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text("I have received the order", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                );
              }

              return _TimelineItem(
                title: step['title'],
                icon: step['icon'],
                isCompleted: isCompleted,
                isCurrent: isCurrent && _currentStatus != 'completed',
                isLast: isLast,
                customContent: customContent,
                statusText: _currentStatus == 'revision-requested' && index == 3 ? "Revision Requested" : null,
              );
            }),
            if (_currentStatus == 'completed') ...[
              const SizedBox(height: AppSpacing.xl),
              if (_orderData!['feedbackRating'] == null)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _showRatingDialog,
                    icon: const Icon(Icons.star),
                    label: const Text("Rate Tailor", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("You rated this tailor ${_orderData!['feedbackRating']} Stars", style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (_orderData!['feedbackComment'] != null && _orderData!['feedbackComment'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('"${_orderData!['feedbackComment']}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
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
            AppLocalizations.of(context)!.trackOrder,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;
  final Widget? customContent;
  final String? statusText;

  const _TimelineItem({
    required this.title,
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
    this.customContent,
    this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted || isCurrent ? AppColors.primary : Colors.grey.shade300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.primary : (isCurrent ? AppColors.primary.withOpacity(0.1) : Colors.transparent),
                border: Border.all(color: color, width: isCurrent ? 2 : 1),
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                size: 16,
                color: isCompleted ? Colors.white : color,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: customContent != null ? 280 : 50,
                color: isCompleted ? AppColors.primary : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isCompleted || isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted || isCurrent ? AppColors.textPrimary : Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
                if (statusText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      statusText!,
                      style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  )
                else if (isCurrent)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "In Progress...",
                      style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                if (customContent != null) customContent!,
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
