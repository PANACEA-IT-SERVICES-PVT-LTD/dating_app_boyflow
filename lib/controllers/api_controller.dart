// lib/controllers/api_controller.dart
import 'package:flutter/foundation.dart';
import '../api_service/api_service.dart';
import '../api_service/api_endpoint.dart';
import '../models/signup_request.dart';

class ApiController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _signupResponse;
  String? _authToken;
  bool _isOtpVerified = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get signupResponse => _signupResponse;
  String? get authToken => _authToken;
  bool get isOtpVerified => _isOtpVerified;

  // ---------- SIGNUP ----------
  Future<bool> signup({required String mobile, required String email}) async {
    _isLoading = true;
    _error = null;
    _signupResponse = null;
    notifyListeners();

    try {
      final payload = SignupRequest(
        email: email,
        mobileNumber: mobile,
      ).toJson();
      debugPrint("📤 Signup request: $payload");

      final res = await _apiService.postData(ApiEndPoints.signup, payload);
      debugPrint("📥 Signup response: $res");

      _signupResponse = res;
      _isLoading = false;

      final ok = res["success"] == true;
      if (ok) {
        notifyListeners();
        return true;
      } else {
        _error = _friendlyMessage(
          res["message"] ?? res["error"] ?? "Signup failed",
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint("❌ Signup exception: $_error");
      notifyListeners();
      return false;
    }
  }

  // ---------- LOGIN: REQUEST OTP ----------
  Future<bool> requestLoginOtp({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payload = {"email": email};
      debugPrint("📤 Request Login OTP: $payload");

      final res = await _apiService.postData(ApiEndPoints.login, payload);
      debugPrint("📥 Request Login OTP response: $res");

      _isLoading = false;

      final ok = res["success"] == true;
      if (ok) {
        notifyListeners();
        return true;
      } else {
        _error = _friendlyMessage(
          res["message"] ?? res["error"] ?? "Failed to send OTP",
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint("❌ Request Login OTP exception: $_error");
      notifyListeners();
      return false;
    }
  }

  // ---------- VERIFY OTP ----------
  Future<bool> verifyOtp({required String otp}) async {
    _isLoading = true;
    _error = null;
    _isOtpVerified = false;
    notifyListeners();

    try {
      final payload = {"otp": otp};
      debugPrint("📤 Verify OTP request: $payload");

      final res = await _apiService.postData(ApiEndPoints.verifyOtp, payload);
      debugPrint("📥 Verify OTP response: $res");

      _isLoading = false;

      final ok = res["success"] == true;
      if (ok) {
        _authToken = res["token"];
        _isOtpVerified = true;
        notifyListeners();
        return true;
      } else {
        _error = _friendlyMessage(
          res["message"] ?? res["error"] ?? "OTP verification failed",
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint("❌ Verify OTP exception: $_error");
      notifyListeners();
      return false;
    }
  }

  // ---------- helpers ----------
  String _friendlyMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains("expired"))
      return "Your OTP has expired. Please request a new one.";
    if (lower.contains("invalid")) return "Invalid OTP. Please try again.";
    if (lower.contains("duplicate"))
      return "This email or phone is already registered.";
    if (lower.contains("not found"))
      return "We couldn’t find an account with that email.";
    return message;
  }
}
