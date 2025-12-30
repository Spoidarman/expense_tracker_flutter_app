import 'api_client.dart';
import 'auth_service.dart';

class MembersService {
  /// Get all members list (using POST method with mess_id)
  static Future<Map<String, dynamic>> getMembers() async {
    try {
      // Get mess_id from logged-in user
      final userData = await AuthService.getUserData();
      final messId = int.tryParse(userData['mess_id'] ?? '1') ?? 1;

      // Backend expects POST request with mess_id
      final response = await ApiClient.post('/admin/members', {
        'mess_id': messId,
      });

      print('Members Request: mess_id=$messId');
      print('Members Response Status: ${response.statusCode}');

      // Handle both 200 and 201 status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiClient.parseResponse(response);
      } else {
        final errorData = ApiClient.parseResponse(response);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Failed to fetch members',
        };
      }
    } catch (e) {
      print('Error fetching members: $e');
      return {'status': false, 'message': 'Connection failed: ${e.toString()}'};
    }
  }

  /// Get member details by ID
  static Future<Map<String, dynamic>> getMemberById(int memberId) async {
    try {
      final response = await ApiClient.post('/admin/members/$memberId', {});

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiClient.parseResponse(response);
      } else {
        final errorData = ApiClient.parseResponse(response);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Failed to fetch member details',
        };
      }
    } catch (e) {
      print('Error fetching member details: $e');
      return {'status': false, 'message': 'Connection failed: ${e.toString()}'};
    }
  }

  /// Update member status (activate/deactivate)
  static Future<Map<String, dynamic>> updateMemberStatus(
    int memberId,
    int status,
  ) async {
    try {
      final response = await ApiClient.put('/admin/members/$memberId/status', {
        'status': status,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiClient.parseResponse(response);
      } else {
        final errorData = ApiClient.parseResponse(response);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Failed to update member status',
        };
      }
    } catch (e) {
      print('Error updating member status: $e');
      return {'status': false, 'message': 'Connection failed: ${e.toString()}'};
    }
  }

  /// Delete member
  static Future<Map<String, dynamic>> deleteMember(int memberId) async {
    try {
      final response = await ApiClient.delete('/admin/members/$memberId');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiClient.parseResponse(response);
      } else {
        final errorData = ApiClient.parseResponse(response);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Failed to delete member',
        };
      }
    } catch (e) {
      print('Error deleting member: $e');
      return {'status': false, 'message': 'Connection failed: ${e.toString()}'};
    }
  }
}
