import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceDataSource {
  static const _deviceIdKey = 'device_id';

  Future<String> getDeviceId() async {
    try {
      // Try to read existing device ID first
      String? deviceId = await _readDeviceId();
      if (deviceId != null && deviceId.isNotEmpty) {
        return deviceId;
      }

      // If no existing ID, generate a new one
      deviceId = await _generateDeviceId();
      await _writeDeviceId(deviceId);
      return deviceId;
    } catch (e) {
      // Fallback to UUID if anything fails
      final deviceId = const Uuid().v4();
      await _writeDeviceId(deviceId);
      return deviceId;
    }
  }

  Future<String> _generateDeviceId() async {
    try {
      // For web platform, we can't use platform-specific code
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          final androidId = await AndroidId().getId();
          if (androidId != null && androidId.isNotEmpty) {
            return "android_$androidId";
          }
        } else if (Platform.isIOS) {
          final deviceInfo = DeviceInfoPlugin();
          final iosInfo = await deviceInfo.iosInfo;
          if (iosInfo.identifierForVendor != null) {
            return "ios_${iosInfo.identifierForVendor!}";
          }
        }
      }
      
      // Fallback for web or when platform detection fails
      return const Uuid().v4();
    } catch (e) {
      // If any platform detection fails, use UUID
      return const Uuid().v4();
    }
  }

  Future<String?> _readDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceIdKey);
  }

  Future<void> _writeDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, deviceId);
  }
}