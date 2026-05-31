import 'dart:async';
import 'package:flutter/foundation.dart';
import '../repositories/notification_repository.dart';

class NotificationService extends ChangeNotifier {
  final NotificationRepository _notificationRepository;

  NotificationService(this._notificationRepository);

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  Timer? _pollingTimer;

  Function(Map<String, dynamic>)? onNewNotification;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchNotifications(isPolling: true);
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  Future<void> fetchNotifications({bool isPolling = false}) async {
    if (!isPolling) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final response = await _notificationRepository.getNotifications();
      final newNotifications = List<Map<String, dynamic>>.from(response['notifications']);
      final newUnreadCount = response['unreadCount'] ?? 0;

      if (isPolling && newUnreadCount > _unreadCount) {
        // Detect the newest unread notification
        final latestUnread = newNotifications.firstWhere(
          (n) => n['isRead'] == false,
          orElse: () => <String, dynamic>{},
        );
        if (latestUnread.isNotEmpty && onNewNotification != null) {
          onNewNotification!(latestUnread);
        }
      }

      _notifications = newNotifications;
      _unreadCount = newUnreadCount;
    } catch (e) {
      if (kDebugMode) print("Error fetching notifications: $e");
    } finally {
      if (!isPolling) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationRepository.markAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n['_id'] == notificationId);
      if (index != -1 && !_notifications[index]['isRead']) {
        _notifications[index]['isRead'] = true;
        _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print("Error marking notification as read: $e");
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationRepository.markAllAsRead();
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error marking all as read: $e");
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationRepository.deleteNotification(notificationId);
      final index = _notifications.indexWhere((n) => n['_id'] == notificationId);
      if (index != -1) {
        if (!_notifications[index]['isRead']) {
          _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
        }
        _notifications.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print("Error deleting notification: $e");
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      await _notificationRepository.deleteAllNotifications();
      _notifications.clear();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error deleting all notifications: $e");
    }
  }
}
