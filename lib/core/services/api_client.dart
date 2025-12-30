import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  static const String baseUrl =
      'http://72.61.244.78/expense-tracker/public/api';

  /// GET request - Token automatically attached
  static Future<http.Response> get(String endpoint) async {
    final token = await AuthService.getToken();

    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(token),
    );
  }

  /// POST request - Token automatically attached
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await AuthService.getToken();

    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(token),
      body: jsonEncode(body),
    );
  }

  /// PUT request - Token automatically attached
  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await AuthService.getToken();

    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(token),
      body: jsonEncode(body),
    );
  }

  /// DELETE request - Token automatically attached
  static Future<http.Response> delete(String endpoint) async {
    final token = await AuthService.getToken();

    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(token),
    );
  }

  /// PATCH request - Token automatically attached
  static Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final token = await AuthService.getToken();

    return await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(token),
      body: jsonEncode(body),
    );
  }

  /// Automatically builds headers with Bearer token
  static Map<String, String> _buildHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Helper method to parse response body
  static Map<String, dynamic> parseResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing response: $e');
      return {'status': false, 'message': 'Invalid response format'};
    }
  }
}
