import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'device_service.dart';

class AuthService {
  static const String baseUrl =
      'http://72.61.244.78/expense-tracker/public/api';
  static const storage = FlutterSecureStorage();

  /// Login with username/email and password
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      // Get device ID
      final deviceId = await DeviceService.getDeviceId();

      print('Connecting to: $baseUrl/auth/login');
      print('Device ID: $deviceId');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'password': password,
              'device_id': deviceId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Check if response has the expected structure (status: true)
        if (responseData['status'] != true) {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Login failed',
          };
        }

        // Extract data from response
        final data = responseData['data'];

        // Verify token and user exist
        if (data == null || data['token'] == null || data['user'] == null) {
          return {'success': false, 'message': 'Missing token or user data'};
        }

        // Store JWT token securely
        await storage.write(key: 'auth_token', value: data['token']);

        // Store user data
        final user = data['user'];
        await storage.write(
          key: 'user_id',
          value: user['id']?.toString() ?? '',
        );
        await storage.write(
          key: 'user_name',
          value: user['name']?.toString() ?? '',
        );
        await storage.write(
          key: 'user_email',
          value: user['email']?.toString() ?? '',
        );
        await storage.write(
          key: 'user_phone',
          value: user['phone']?.toString() ?? '',
        );
        await storage.write(
          key: 'role_id',
          value: user['role_id']?.toString() ?? '',
        );
        await storage.write(
          key: 'aadhar_no',
          value: user['aadhar_no']?.toString() ?? '',
        );
        await storage.write(
          key: 'mess_id',
          value: user['mess_id']?.toString() ?? '0',
        );
        await storage.write(key: 'dob', value: user['dob']?.toString() ?? '');

        print('Login successful! User: ${user['name']}');

        return {
          'success': true,
          'data': data,
          'user': user,
          'message': responseData['message'] ?? 'Login successful',
        };
      } else {
        // Handle error responses
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Invalid credentials',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.statusCode}',
          };
        }
      }
    } on http.ClientException catch (e) {
      print('Client Exception: $e');
      return {
        'success': false,
        'message': 'Cannot connect to server. Check your internet connection.',
      };
    } on FormatException catch (e) {
      print('Format Exception: $e');
      return {
        'success': false,
        'message': 'Invalid response format from server',
      };
    } catch (e) {
      print('Error: $e');
      return {
        'success': false,
        'message': 'Connection failed: ${e.toString()}',
      };
    }
  }

  /// Get stored token
  static Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  /// Get user data
  static Future<Map<String, String?>> getUserData() async {
    return {
      'user_id': await storage.read(key: 'user_id'),
      'user_name': await storage.read(key: 'user_name'),
      'user_email': await storage.read(key: 'user_email'),
      'user_phone': await storage.read(key: 'user_phone'),
      'role_id': await storage.read(key: 'role_id'),
      'mess_id': await storage.read(key: 'mess_id'),
      'aadhar_no': await storage.read(key: 'aadhar_no'),
      'dob': await storage.read(key: 'dob'),
    };
  }

  /// Logout
  static Future<void> logout() async {
    // Delete all except device_id
    final deviceId = await storage.read(key: 'device_id');
    await storage.deleteAll();
    if (deviceId != null) {
      await storage.write(key: 'device_id', value: deviceId);
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }
}
