import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AIService {
  static const String baseUrl = "http://172.23.181.1:8000";

  Future<List<dynamic>> getSuggestions({
    required String occasion,
    required String season,
    required String fabric,
    required String color,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/recommend"),

      headers: {"Content-Type": "application/json"},

      body: jsonEncode({
        "occasion": occasion,
        "season": season,
        "fabric": fabric,
        "color": color,
      }),
    );

    debugPrint(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch AI suggestions");
    }
  }

  Future<List<dynamic>> getImageSuggestions({
    required String occasion,
    required String season,
    required String fabric,
    required String color,
  }) async {
    try {
      final uri = Uri.parse("http://172.23.181.1:5000/api/suggestions/images")
          .replace(
            queryParameters: {
              "occasion": occasion,
              "season": season,
              "fabric": fabric,
              "color": color,
            },
          );

      final user = FirebaseAuth.instance.currentUser;
      String? token;
      if (user != null) {
        token = await user.getIdToken();
      }

      final response = await http.get(
        uri,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching image suggestions: $e");
      return [];
    }
  }
}
