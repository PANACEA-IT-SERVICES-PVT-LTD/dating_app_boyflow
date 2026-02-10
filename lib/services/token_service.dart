import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Base URL for your token server. Override at build time with --dart-define.
const String kTokenServerBaseUrl = String.fromEnvironment(
  'TOKEN_BASE_URL',
  defaultValue: 'https://your-api-server.com',
);

class TokenService {
  static const String _deviceIdKey = 'device_id';
  static String? _overrideDeviceId;

  static Future<String> getOrCreateDeviceId() async {
    if (_overrideDeviceId != null && _overrideDeviceId!.isNotEmpty) {
      return _overrideDeviceId!;
    }
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    await prefs.setString(_deviceIdKey, newId);
    return newId;
  }

  static Future<void> setDeviceId(String deviceId) async {
    _overrideDeviceId = deviceId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, deviceId);
  }

  static Future<String> getCurrentDeviceId() async {
    return getOrCreateDeviceId();
  }

  static Future<String> fetchToken({
    required String channelName,
    required int uid,
  }) async {
    // Placeholder for token generation - replace with your own token service
    return '';
  }

  static Future<void> registerFcmToken(String token) async {
    try {
      final deviceId = await getOrCreateDeviceId();
      final uri = Uri.parse('$kTokenServerBaseUrl/register-token');
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'deviceId': deviceId, 'fcmToken': token}),
      );
    } catch (e) {}
  }
}
