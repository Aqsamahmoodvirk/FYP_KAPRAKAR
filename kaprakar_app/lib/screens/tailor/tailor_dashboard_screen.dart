import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../services/tailor_service.dart';
import '../../routes/app_routes.dart';
import '../../services/journey_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';
import '../../services/chat_service.dart';
import '../../services/notification_service.dart';
import '../../utils/top_snackbar.dart';
import '../../widgets/app_drawer.dart';
class TailorDashboardScreen extends StatefulWidget {
  const TailorDashboardScreen({super.key});

  @override
  State<TailorDashboardScreen> createState() => _TailorDashboardScreenState();
}

class _TailorDashboardScreenState extends State<TailorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tailorService = context.read<TailorService>();
      final chatService = context.read<ChatService>();
      final userId = JourneyService().currentUserId;
      if (userId != null) {
        // Init Chats
        chatService.connectSocket(userId);
        chatService.fetchUserChats(userId);

        // Init Tailor Profile
        JourneyService().fetchUserProfile(userId);
        tailorService.fetchTailorProfile(userId).then((_) {
          final tailorId = tailorService.profile?['_id'];
          if (tailorId != null) {
            tailorService.fetchTailorOrders(tailorId);
            tailorService.fetchTailorStats(tailorId);
          }
        });

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
      }
    });
  }

  @override
  void dispose() {
    context.read<NotificationService>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tailorService = context.watch<TailorService>();
    final stats = tailorService.stats;
    
    final int earnings = stats?['totalEarnings'] ?? 0;
    final int completed = stats?['ordersCompletedThisMonth'] ?? 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      body: tailorService.isLoading && tailorService.profile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                final userId = JourneyService().currentUserId;
                if (userId != null) {
                  await tailorService.fetchTailorProfile(userId);
                  final tailorId = tailorService.profile?['_id'];
                  if (tailorId != null) {
                    await tailorService.fetchTailorOrders(tailorId);
                    await tailorService.fetchTailorStats(tailorId);
                  }
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildWelcomeHeader(context, context.watch<JourneyService>().userName.isNotEmpty ? context.watch<JourneyService>().userName : 'Tailor'),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...() {
                            final profile = tailorService.profile;
                            return [
                              // Premium Financial Wallet Card
                              _buildPremiumWalletCard(context, earnings, completed, profile),
                              
                              const SizedBox(height: AppSpacing.xxl),

                              // Queue Summary Title
                              Text(
                                AppLocalizations.of(context)!.queueSummary, 
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              
                              // Queue Grid
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQueueCard(
                                      context, 
                                      'Inbox Request', 
                                      '${tailorService.pendingOrders.length}', 
                                      Icons.mark_email_unread_rounded, 
                                      AppRoutes.orderInbox,
                                      AppColors.primary, 
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: _buildQueueCard(
                                      context, 
                                      'Active Orders', 
                                      '${tailorService.activeOrders.length}', 
                                      Icons.work_history_rounded, 
                                      AppRoutes.activeOrders,
                                      const Color(0xFF004D54), // Dark Teal instead of primary
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQueueCard(
                                      context, 
                                      'Customer Reviews', 
                                      '${tailorService.orders.where((o) => o['feedbackRating'] != null).length}', 
                                      Icons.star_rounded, 
                                      AppRoutes.tailorReviews,
                                      AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(child: SizedBox.shrink()),
                                ],
                              ),
                            ];
                          }(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, String name) {
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
            padding: const EdgeInsets.only(left: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, $name",
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Here is your business overview",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumWalletCard(BuildContext context, int earnings, int completed, Map<String, dynamic>? profile) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, const Color(0xFF004D54)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background subtle pattern
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.account_balance_wallet, size: 150, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.totalEarningsThisMonth, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                  if (profile != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.accentGold, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "${((profile['rating'] ?? 0) as num).toStringAsFixed(1)} (${profile['reviewCount'] ?? 0})",
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'PKR $earnings',
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('COMPLETED', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('$completed Orders', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.tailorWallet),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wallet, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context)!.myWallet,
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQueueCard(BuildContext context, String title, String count, IconData icon, String route, Color tintColor) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tintColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: tintColor, size: 28),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (count.isNotEmpty)
              Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
