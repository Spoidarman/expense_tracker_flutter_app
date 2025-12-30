import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static const storage = FlutterSecureStorage();
  static const String _deviceIdKey = 'device_id';

  /// Get or generate a unique device ID
  static Future<String> getDeviceId() async {
    // Try to read existing device ID from secure storage
    String? deviceId = await storage.read(key: _deviceIdKey);

    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }

    // Generate new device ID if doesn't exist
    deviceId = await _generateDeviceId();

    // Store it securely
    await storage.write(key: _deviceIdKey, value: deviceId);

    return deviceId;
  }

  /// Generate a unique device ID
  static Future<String> _generateDeviceId() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // Use Android ID or generate UUID
        return androidInfo.id ?? const Uuid().v4();
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        // Use identifierForVendor or generate UUID
        return iosInfo.identifierForVendor ?? const Uuid().v4();
      } else {
        // Fallback to UUID for other platforms
        return const Uuid().v4();
      }
    } catch (e) {
      // If device info fails, generate UUID
      return const Uuid().v4();
    }
  }

  /// Clear stored device ID (for testing purposes)
  static Future<void> clearDeviceId() async {
    await storage.delete(key: _deviceIdKey);
  }
}
