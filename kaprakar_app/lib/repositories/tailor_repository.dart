import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class TailorRepository {
  Future<List<Map<String, dynamic>>> getTailorOrders(String tailorId);
  Future<Map<String, dynamic>> getTailorStats(String tailorId);
  Future<List<Map<String, dynamic>>> getTailorWallet(String tailorId);
  Future<Map<String, dynamic>> getTailorByUserId(String userId);
  Future<List<Map<String, dynamic>>> getAllTailors({
    String? search,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? location,
    String? category,
  });
  Future<Map<String, dynamic>> createTailorProfile(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateTailorProfile(
    String tailorId,
    Map<String, dynamic> data,
  );
  Future<String> uploadProfileImage(String tailorId, String imagePath);
}

class ApiTailorRepository implements TailorRepository {
  // Use laptop IP or localhost mapping for physical device
  // Update this to your IP (e.g. 172.23.181.1) or localhost if using ADB reverse
  final String baseUrl = "http://172.23.181.1:5000/api";

  @override
  Future<List<Map<String, dynamic>>> getTailorOrders(String tailorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/tailor/$tailorId'),
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load tailor orders');
  }

  @override
  Future<Map<String, dynamic>> getTailorStats(String tailorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tailors/$tailorId/stats'),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load tailor stats');
  }

  @override
  Future<List<Map<String, dynamic>>> getTailorWallet(String tailorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/payment/tailor/$tailorId/wallet'),
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load wallet transactions');
  }

  @override
  Future<Map<String, dynamic>> getTailorByUserId(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/tailors/user/$userId'));
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load tailor profile');
  }

  @override
  Future<List<Map<String, dynamic>>> getAllTailors({
    String? search,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? location,
    String? category,
  }) async {
    final Map<String, String> queryParams = {};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (minRating != null) queryParams['minRating'] = minRating.toString();
    if (location != null && location.isNotEmpty)
      queryParams['location'] = location;
    if (category != null && category.isNotEmpty)
      queryParams['category'] = category;

    final uri = Uri.parse(
      '$baseUrl/tailors',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load tailors list');
  }

  @override
  Future<Map<String, dynamic>> createTailorProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tailors/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to create tailor profile: ${response.body}');
  }

  @override
  Future<Map<String, dynamic>> updateTailorProfile(
    String tailorId,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tailors/$tailorId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to update tailor profile: ${response.body}');
  }

  @override
  Future<String> uploadProfileImage(String tailorId, String imagePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/tailors/$tailorId/profile-image'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['profileImage'] as String;
    }
    throw Exception('Failed to upload profile image: ${response.body}');
  }
}
