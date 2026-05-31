import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class TripoService {
  final String baseUrl = "http://172.23.181.1:5000/api";

  Future<String?> generate3DModel(String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/3d/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imageUrl': imageUrl}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['taskId'];
      } else {
        print('Failed to generate 3D model: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating 3D model: $e');
      return null;
    }
  }

  Stream<Map<String, dynamic>> pollTaskStatus(String taskId) async* {
    while (true) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/3d/status/$taskId'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          yield data;

          if (data['status'] == 'success' || data['status'] == 'failed') {
            break; // Stop polling
          }
        } else {
          yield {'status': 'error', 'message': 'Failed to poll status'};
          break;
        }
      } catch (e) {
        yield {'status': 'error', 'message': e.toString()};
        break;
      }

      await Future.delayed(const Duration(seconds: 3));
    }
  }
}
