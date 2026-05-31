import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

abstract class NotificationRepository {
  Future<Map<String, dynamic>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> deleteAllNotifications();
}

class ApiNotificationRepository implements NotificationRepository {
  final String baseUrl = "http://172.23.181.1:5000/api";

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService().getFirebaseToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<Map<String, dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load notifications');
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$notificationId'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/delete-all'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete all notifications');
    }
  }
}
