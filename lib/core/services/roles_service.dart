import 'api_client.dart';
import 'auth_service.dart';

class RolesService {
  /// Get all roles list
  static Future<Map<String, dynamic>> getRoles() async {
    try {
      // Get mess_id from logged-in user
      final userData = await AuthService.getUserData();
      final messId = int.tryParse(userData['mess_id'] ?? '1') ?? 1;

      // Backend expects POST request with mess_id
      final response = await ApiClient.post('/admin/role-list', {
        'mess_id': messId,
      });

      print('Roles Request: mess_id=$messId');
      print('Roles Response Status: ${response.statusCode}');
      print('Roles Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiClient.parseResponse(response);
      } else {
        final errorData = ApiClient.parseResponse(response);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Failed to fetch roles',
        };
      }
    } catch (e) {
      print('Error fetching roles: $e');
      return {'status': false, 'message': 'Connection failed: ${e.toString()}'};
    }
  }
}
