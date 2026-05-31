import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_radius.dart';
import '../../routes/app_routes.dart';
import '../../services/journey_service.dart';
import '../../services/notification_service.dart';
import 'package:kaprakar_app/l10n/app_localizations.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationService>().fetchNotifications();
    });
  }

  void _handleTap(Map<String, dynamic> notif) async {
    final String id = notif['_id'] as String? ?? '';
    final String type = notif['type'] as String? ?? '';
    final String? orderId = notif['relatedOrderId'] as String?;
    final String? chatId = notif['relatedChatId'] as String?;
    final service = JourneyService();
    final bool isTailor = service.userRole.toLowerCase() == 'tailor';

    // Mark read
    if (notif['isRead'] == false) {
      context.read<NotificationService>().markAsRead(id);
    }

    if (!mounted) return;
    switch (type) {
      case 'order_update':
        if (orderId != null) {
          if (isTailor) {
            Navigator.pushNamed(
              context,
              AppRoutes.orderDetail,
              arguments: orderId,
            );
          } else {
            Navigator.pushNamed(
              context,
              AppRoutes.trackOrder,
              arguments: orderId,
            );
          }
        }
        break;
      case 'revision_request':
        if (orderId != null) {
          if (isTailor) {
            Navigator.pushNamed(
              context,
              AppRoutes.revisionInbox,
              arguments: {'orderId': orderId},
            );
          } else {
            Navigator.pushNamed(
              context,
              AppRoutes.changeRequest,
              arguments: {'orderId': orderId},
            );
          }
        }
        break;
      case 'order_complete':
        if (orderId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.orderCompletion,
            arguments: {
              'orderId': orderId,
              'userRole': isTailor ? 'tailor' : 'customer',
            },
          );
        }
        break;
      case 'message':
        if (chatId != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.chatDetail,
            arguments: {
              'id': chatId,
              'tailorName': notif['title'] ?? 'Chat',
              'isOnline': false,
            },
          );
        }
        break;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'order_update':
        return Icons.shopping_bag_outlined;
      case 'revision_request':
        return Icons.edit_outlined;
      case 'order_complete':
        return Icons.check_circle_outline;
      case 'message':
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'order_update':
        return AppColors.primary;
      case 'revision_request':
        return AppColors.secondary;
      case 'order_complete':
        return AppColors.success;
      case 'message':
        return AppColors.accentGold;
      default:
        return AppColors.textSecondary;
    }
  }

  String _timeAgo(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  Widget _buildNotificationTile(Map<String, dynamic> notif) {
    final bool isRead = notif['isRead'] == true;
    final String type = notif['type'] as String? ?? '';
    final Color typeColor = _colorForType(type);
    final String timeAgo = _timeAgo(notif['createdAt'] as String?);
    
    // Ensure we don't render completely blank boxes if data is corrupt
    final String title = notif['title']?.toString().isNotEmpty == true ? notif['title'] : 'Notification';
    final String body = notif['body']?.toString().isNotEmpty == true ? notif['body'] : 'You have a new update.';

    return Dismissible(
      key: Key(notif['_id'] ?? UniqueKey().toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: AppSpacing.md),
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        context.read<NotificationService>().deleteNotification(notif['_id']);
      },
      child: GestureDetector(
        onTap: () => _handleTap(notif),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isRead ? Theme.of(context).cardColor : typeColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead ? AppColors.border.withValues(alpha: 0.5) : typeColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isRead ? Colors.black : typeColor).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_iconForType(type), color: typeColor, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                color: isRead ? AppColors.textPrimary : typeColor.withOpacity(0.8).withBlue(50).withRed(50),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: typeColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: typeColor.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        body,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isRead ? AppColors.textSecondary : AppColors.textPrimary.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            timeAgo, 
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l.noNotifications,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'When you have updates on your orders or messages, they will appear here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final notifService = context.watch<NotificationService>();
    final notifications = notifService.notifications;
    final unreadCount = notifService.unreadCount;
    final isLoading = notifService.isLoading;

    final unreadList = notifications.where((n) => n['isRead'] == false).toList();
    final readList = notifications.where((n) => n['isRead'] == true).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context, notifService, notifications.isNotEmpty, l),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : notifications.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: _buildEmptyState(l),
                  )
                : RefreshIndicator(
                    onRefresh: notifService.fetchNotifications,
                    color: AppColors.primary,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      children: [
                        if (unreadList.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.sm, top: AppSpacing.sm),
                            child: Text('New', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary)),
                          ),
                          ...unreadList.map((n) => _buildNotificationTile(n)),
                        ],
                        if (readList.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.sm, top: unreadList.isNotEmpty ? AppSpacing.xl : AppSpacing.sm),
                            child: Text('Older', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                          ),
                          ...readList.map((n) => _buildNotificationTile(n)),
                        ],
                        const SizedBox(height: 40), // Bottom padding
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NotificationService notifService, bool hasNotifications, AppLocalizations l) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.notificationsTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (hasNotifications)
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.white70),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete All'),
                        content: const Text('Are you sure you want to delete all notifications?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              notifService.deleteAllNotifications();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Delete All', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                  },
                  tooltip: 'Delete All',
                ),
            ],
          ),
          if (notifService.unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0),
              child: GestureDetector(
                onTap: notifService.markAllAsRead,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.done_all, color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      l.markAllRead,
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
