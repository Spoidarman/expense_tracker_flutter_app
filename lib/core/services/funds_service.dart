import 'api_client.dart';
import 'auth_service.dart';

class FundsService {
  static Future<Map<String, dynamic>> addFund({
    required int messId,
    required int userId,
    required String fundDate,
    required double amount,
    required String notes,
  }) async {
    try {
      final response = await ApiClient.post('/admin/fundexpense/fund-add', {
        'mess_id': messId,
        'user_id': userId,
        'fund_date': fundDate,
        'amount': amount,
        'notes': notes,
        'is_add': 1,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiClient.parseResponse(response);
      } else {
        final errorData = ApiClient.parseResponse(response);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Failed to add fund',
        };
      }
    } catch (e) {
      print('Error adding fund: $e');
      return {'status': false, 'message': 'Connection failed: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> editFund({
    required int id,
    required int messId,
    required int userId,
    required String fundDate,
    required double amount,
    required String notes,
  }) async {
    try {
      final response = await ApiClient.post('/admin/fundexpense/fund-add', {
        'id': id,
        'mess_id': messId,
        'user_id': userId,
        'fund_date': fundDate,
        'amount': amount,
        'notes': notes,
        'is_edit': 1,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiClient.parseResponse(response);
      } else {
        final errorData = ApiClient.parseResponse(response);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Failed to update fund',
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'Connection failed: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> deleteFund({
    required int id,
    required int messId,
    required int userId,
    required String fundDate,
    required double amount,
    required String notes,
  }) async {
    try {
      final response = await ApiClient.post('/admin/fundexpense/fund-add', {
        'id': id,
        'mess_id': messId,
        'user_id': userId,
        'fund_date': fundDate,
        'amount': amount,
        'notes': notes,
        'is_delete': 1,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiClient.parseResponse(response);
      } else {
        final errorData = ApiClient.parseResponse(response);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Failed to delete fund',
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'Connection failed: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> getFunds() async {
    try {
      final userData = await AuthService.getUserData();
      final messId = int.tryParse(userData['mess_id'] ?? '1') ?? 1;

      final response = await ApiClient.post('/admin/fundexpense/fund-list', {
        'mess_id': messId,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiClient.parseResponse(response);
      } else {
        final errorData = ApiClient.parseResponse(response);
        return {
          'status': false,
          'message': errorData['message'] ?? 'Failed to fetch funds',
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'Connection failed: ${e.toString()}'};
    }
  }
}
