import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class ChatRepository {
  Future<List<Map<String, dynamic>>> getUserChats(String userId);
  Future<Map<String, dynamic>> accessChat(
    String currentUserId,
    String otherUserId,
  );
  Future<List<Map<String, dynamic>>> getMessages(String chatId);
  Future<void> sendMessage(Map<String, dynamic> msgData);
  Future<void> deleteChat(String chatId);
  Future<void> deleteMessage(String messageId);
  Future<void> markChatAsRead(String chatId, String userId);
}

class ApiChatRepository implements ChatRepository {
  // Use laptop IP or localhost mapping for physical device
  final String baseUrl = "http://192.168.0.101.1:5000/api";

  @override
  Future<List<Map<String, dynamic>>> getUserChats(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/chats/user/$userId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load user chats');
  }

  @override
  Future<Map<String, dynamic>> accessChat(
    String currentUserId,
    String otherUserId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chats/access'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId1': currentUserId, 'userId2': otherUserId}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to access chat');
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chats/messages/$chatId'),
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load messages');
  }

  @override
  Future<void> sendMessage(Map<String, dynamic> msgData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chats/message'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(msgData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to save message to database');
    }
  }

  @override
  Future<void> deleteChat(String chatId) async {
    final response = await http.delete(Uri.parse('$baseUrl/chats/$chatId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete chat');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/chats/message/$messageId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete message');
    }
  }

  @override
  Future<void> markChatAsRead(String chatId, String userId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/chats/$chatId/read'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark chat as read');
    }
  }
}
