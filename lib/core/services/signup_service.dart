import 'dart:convert';
import 'package:http/http.dart' as http;
import 'device_service.dart';

class SignupService {
  static const String baseUrl =
      'http://72.61.244.78/expense-tracker/public/api';

  static Future<Map<String, dynamic>> register({
    required int roleId,
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
      final deviceId = await DeviceService.getDeviceId();

      print('Connecting to: $baseUrl/auth/register');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'role_id': roleId,
              'name': name,
              'email': email,
              'phone': phone,
              'aadhar_no': aadharNo,
              'dob': dob,
              'password': password,
              'guardian_name': guardianName,
              'guardian_phone': guardianPhone,
              'device_id': deviceId,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == true) {
          return {
            'success': true,
            'data': responseData['data'],
            'message': responseData['message'] ?? 'Registration successful',
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
          return {
            'success': false,
            'message': errorData['message'] ?? 'Registration failed',
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
