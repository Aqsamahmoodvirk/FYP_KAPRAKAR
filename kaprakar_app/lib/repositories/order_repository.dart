import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

abstract class OrderRepository {
  Future<List<Map<String, dynamic>>> getCustomerOrders(String customerId);
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData);
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> completeOrder(String orderId, String imagePath);
  Future<void> submitFeedback(String orderId, int rating, String comment);
  Future<void> deleteOrder(String orderId);
}

class ApiOrderRepository implements OrderRepository {
  // Use 172.23.181.1 for Android emulator to connect to localhost backend
  final String baseUrl = "http://172.23.181.1:5000/api";

  @override
  Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(orderData),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body)['order'];
    }
    throw Exception('Failed to create order: ${response.body}');
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerOrders(
    String customerId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/customer/$customerId'),
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load orders');
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/orders/$orderId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update status: ${response.body}');
    }
  }

  @override
  Future<void> completeOrder(String orderId, String imagePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/orders/$orderId/complete'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('dressImage', imagePath),
    );
    var response = await request.send();
    if (response.statusCode != 200) {
      final resStr = await response.stream.bytesToString();
      throw Exception('Failed to complete order: $resStr');
    }
  }

  @override
  Future<void> submitFeedback(
    String orderId,
    int rating,
    String comment,
  ) async {
    final token = await AuthService().getFirebaseToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/feedback'),
      headers: headers,
      body: jsonEncode({'rating': rating, 'comment': comment}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to submit feedback: ${response.body}');
    }
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    final response = await http.delete(Uri.parse('$baseUrl/orders/$orderId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete order: ${response.body}');
    }
  }
}
