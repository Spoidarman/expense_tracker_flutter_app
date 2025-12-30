import 'dart:convert';
import 'package:http/http.dart' as http;
import 'device_service.dart';
import 'auth_service.dart';

class RegistrationService {
  static const String baseUrl =
      'http://72.61.244.78/expense-tracker/public/api';

  /// Register a new member (requires authentication)
  static Future<Map<String, dynamic>> registerMember({
    required int roleId,
    required int messId,
    required String name,
    required String email,
    required String phone,
    required String aadharNo,
    required String dob,
    required String password,
    required String guardianName,
    required String guardianPhone,
  }) async {
    try {
      // Get auth token for authenticated request
      final token = await AuthService.getToken();
      final deviceId = await DeviceService.getDeviceId();

      final requestBody = {
        'role_id': roleId,
        'mess_id': messId,
        'name': name,
        'email': email,
        'phone': phone,
        'aadhar_no': aadharNo,
        'dob': dob,
        'password': password,
        'guardian_name': guardianName,
        'guardian_phone': guardianPhone,
        'device_id': deviceId,
      };

      print('=== Registration Request ===');
      print('URL: $baseUrl/auth/register');
      print(
        'Token: ${token != null ? "Present (${token.substring(0, 15)}...)" : "Missing"}',
      );
      print('Request Body: ${jsonEncode(requestBody)}');
      print('========================');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      print('=== Registration Response ===');
      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');
      print('========================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == true) {
          return {
            'success': true,
            'data': responseData['data'],
            'message':
                responseData['message'] ?? 'Member registered successfully',
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Registration failed',
          };
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);

          // Extract more detailed error information
          String errorMessage = errorData['message'] ?? 'Registration failed';

          // Check if it's a validation error with details
          if (errorData['errors'] != null) {
            final errors = errorData['errors'] as Map<String, dynamic>;
            final errorList = errors.values.expand((e) => e as List).toList();
            errorMessage = errorList.join(', ');
          }

          return {'success': false, 'message': errorMessage};
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.statusCode}',
          };
        }
      }
    } on http.ClientException catch (e) {
      print('Client Exception: $e');
      return {'success': false, 'message': 'Cannot connect to server'};
    } on FormatException catch (e) {
      print('Format Exception: $e');
      return {'success': false, 'message': 'Invalid response format'};
    } catch (e) {
      print('Error: $e');
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }
}
