import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

Future<void> saveLoginToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  debugPrint('Saved login token: $token');
}
