import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://172.23.181.1:5000';
  //static const String baseUrl = 'http://192.168.100.208:5000';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login
  Future<UserCredential> loginUser(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register
  Future<UserCredential> registerUser(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get Firebase Token
  Future<String?> getFirebaseToken() async {
    User? user = _auth.currentUser;

    if (user != null) {
      return await user.getIdToken();
    }

    return null;
  }

  // Sync user to backend
  Future<Map<String, dynamic>> syncUser(
    String token, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse("http://172.23.181.1:5000/api/auth/syncUser"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sync user: ${response.body}');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile(
    String userId,
    Map<String, dynamic> body,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/api/auth/user/$userId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }
}
