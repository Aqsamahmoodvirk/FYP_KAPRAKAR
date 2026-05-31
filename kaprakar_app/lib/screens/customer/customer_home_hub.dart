import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/primary_button.dart';
import '../../routes/app_routes.dart';
import '../../services/journey_service.dart';
import '../../widgets/app_drawer.dart';
import '../../services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';
import '../../services/chat_service.dart';
import '../../repositories/order_repository.dart';
import '../../utils/top_snackbar.dart';

class CustomerHomeHub extends StatefulWidget {
  const CustomerHomeHub({super.key});

  @override
  State<CustomerHomeHub> createState() => _CustomerHomeHubState();
}

class _CustomerHomeHubState extends State<CustomerHomeHub> {
  List<Map<String, dynamic>> _myOrders = [];
  bool _isLoadingOrders = true;

  // Listen to service for updates (e.g., active order changes)
  void _onServiceUpdate() {
    setState(() {});
    _fetchMyOrders();
  }

  @override
  void initState() {
    super.initState();
    JourneyService().addListener(_onServiceUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatService = context.read<ChatService>();
      final journeyService = context.read<JourneyService>();
      final myUserId = journeyService.currentUserId ?? "";
      if (myUserId.isNotEmpty) {
        // Init Chats
        chatService.connectSocket(myUserId);
        chatService.fetchUserChats(myUserId);
        // Init User Profile for Dashboard/Drawer Name Display
        journeyService.fetchUserProfile(myUserId);
        // Init Notifications
        final notifService = context.read<NotificationService>();
        notifService.onNewNotification = (notif) {
          if (!mounted) return;
          TopSnackBar.show(
            context,
            "${notif['title']}: ${notif['body']}",
            onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
          );
        };
        notifService.fetchNotifications();
        notifService.startPolling();
        // Fetch all orders
        _fetchMyOrders();
      }
    });
  }

  Future<void> _fetchMyOrders() async {
    try {
      final myUserId = JourneyService().currentUserId;
      if (myUserId == null) return;
      final repo = ApiOrderRepository();
      final orders = await repo.getCustomerOrders(myUserId);
      if (mounted) {
        setState(() {
          _myOrders = orders.where((o) => o['status'] != 'completed' && o['status'] != 'rejected').toList();
          _myOrders.sort((a, b) {
            final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(2000);
            final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(2000);
            return dateB.compareTo(dateA);
          });
          _isLoadingOrders = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingOrders = false);
      debugPrint("Failed to fetch orders: $e");
    }
  }

  @override
  void dispose() {
    JourneyService().removeListener(_onServiceUpdate);
    context.read<NotificationService>().stopPolling();
    super.dispose();
  }

  void _onStartNewOrder() {
    final service = JourneyService();
    
    // 1. Reset journey specific flags (AI, Tailor) but keep measurements
    service.startNewOrder();

    // 2. Check logic: Measurements First
    if (service.hasMeasurements) {
      // Skip to Dashboard (Step 2/3) if measurements exist
      Navigator.pushNamed(context, AppRoutes.home); // "Home" is now the Journey Dashboard
    } else {
      // Go to Measurement Input
      Navigator.pushNamed(context, AppRoutes.measurement);
    }
  }

  Future<void> _handleRefresh() async {
    final myUserId = JourneyService().currentUserId;
    if (myUserId != null && myUserId.isNotEmpty) {
      await Future.wait([
        _fetchMyOrders(),
        context.read<ChatService>().fetchUserChats(myUserId),
        JourneyService().fetchUserProfile(myUserId),
        context.read<NotificationService>().fetchNotifications(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeBanner(context),
              
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(AppLocalizations.of(context)!.trackMyOrders, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
              const SizedBox(height: AppSpacing.md),

              if (_isLoadingOrders)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_myOrders.isNotEmpty)
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: _myOrders.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: _buildActiveOrderCard(context, _myOrders[index]),
                      );
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _buildEmptyState(context),
                ),

              const SizedBox(height: AppSpacing.xl),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(AppLocalizations.of(context)!.newCreation, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
              const SizedBox(height: AppSpacing.md),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _buildPremiumCTA(context),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    final String fullUserName = context.watch<JourneyService>().userName;
    final userName = fullUserName.isNotEmpty ? fullUserName : 'User';
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: AppSpacing.lg, 
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              Row(
                children: [
                  Consumer<ChatService>(
                    builder: (context, chatService, child) {
                      final unreadChats = chatService.chats.where((c) => (c['unreadCount'] ?? 0) > 0).length;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.chatsList),
                          ),
                          if (unreadChats > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadChats > 9 ? '9+' : unreadChats.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  Consumer<NotificationService>(
                    builder: (context, notificationService, child) {
                      final unreadCount = notificationService.unreadCount;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none, color: Colors.white),
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: Text(
              "Welcome, $userName!",
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Text(
              "Ready to design your next masterpiece?",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.style_outlined, color: AppColors.textSecondary.withValues(alpha: 0.5), size: 48),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.noOrdersYet, style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(BuildContext context, Map<String, dynamic> order) {
    final String rawId = order['_id'].toString();
    final String shortId = order['orderNumber']?.toString() ?? (rawId.length > 6 ? rawId.substring(rawId.length - 6).toUpperCase() : rawId);
    final String dressType = order['dressType'] ?? 'Custom Dress';
    
    String dateStr = 'Recent';
    if (order['createdAt'] != null) {
      final date = DateTime.tryParse(order['createdAt']);
      if (date != null) {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        dateStr = "${months[date.month - 1]} ${date.day}";
      }
    }

    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.trackOrder, arguments: order['_id']),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(dateStr, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                Icon(Icons.arrow_forward_ios, color: AppColors.primary.withValues(alpha: 0.5), size: 14),
              ],
            ),
            const Spacer(),
            Text(dressType, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text("Order #$shortId", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${order['status'] ?? 'Processing'}", 
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCTA(BuildContext context) {
    return InkWell(
      onTap: _onStartNewOrder,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF004D54)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  AppLocalizations.of(context)!.designYourOutfit,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.startANewStitchingJourneyWeGui,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                ),
              ],
            ),
            Positioned(
              right: -10,
              top: -10,
              child: Icon(Icons.cut_outlined, size: 100, color: Colors.white.withValues(alpha: 0.15)),
            ),
          ],
        ),
      ),
    );
  }
}
