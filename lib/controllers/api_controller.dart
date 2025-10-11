import 'package:flutter/foundation.dart';
import 'package:Boy_flow/models/profiledetails.dart';
import '../api_service/api_service.dart';
import '../api_service/api_endpoint.dart';
import '../models/profiledetails.dart';

class ApiController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _signupResponse;
  String? _authToken;
  bool _isOtpVerified = false;

  // Remember identity + context for OTP verify
  String? _pendingEmail;
  String? _pendingMobile;
  String? _pendingSource; // "login" | "signup"
  String? _otpRequestId; // from send-OTP
  String? _otpChannel; // "email" | "mobile"

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get signupResponse => _signupResponse;
  String? get authToken => _authToken;
  bool get isOtpVerified => _isOtpVerified;

  // ---------- helpers (public) ----------
  void setPendingIdentity({String? email, String? mobile, String? source}) {
    if (email != null && email.isNotEmpty) _pendingEmail = email.trim();
    if (mobile != null && mobile.isNotEmpty) _pendingMobile = mobile.trim();
    if (source != null && source.isNotEmpty) {
      _pendingSource = source.trim().toLowerCase();
    }
    _otpChannel = (email != null && email.isNotEmpty)
        ? "email"
        : (mobile != null && mobile.isNotEmpty)
        ? "mobile"
        : _otpChannel;
  }

  void _captureOtpRequestId(dynamic res) {
    final data = (res is Map) ? res["data"] : null;
    final candidates = [
      if (res is Map) ...[
        res["requestId"],
        res["otpId"],
        res["txnId"],
        res["sessionId"],
        res["id"],
        res["otpRequestId"],
        res["request_id"],
        res["otp_request_id"],
      ],
      if (data is Map) ...[
        data["requestId"],
        data["otpId"],
        data["txnId"],
        data["sessionId"],
        data["id"],
        data["otpRequestId"],
        data["request_id"],
        data["otp_request_id"],
      ],
    ].where((v) => v != null).map((v) => v.toString()).toList();

    _otpRequestId = candidates.isNotEmpty ? candidates.first : null;
    debugPrint("🔖 Captured OTP request id: $_otpRequestId");
  }

  String _normalizeOtp(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    return digits.isNotEmpty ? digits : raw.trim();
  }

  // ---------- SIGNUP ----------
  Future<bool> signup({required String mobile, required String email}) async {
    _isLoading = true;
    _error = null;
    _signupResponse = null;
    notifyListeners();

    try {
      final payload = {"email": email.trim(), "mobileNumber": mobile.trim()};
      debugPrint("📤 Signup request: $payload");

      final res = await _apiService.postData(ApiEndPoints.signup, payload);
      debugPrint("📥 Signup response: $res");

      _signupResponse = res;
      _isLoading = false;

      setPendingIdentity(email: email, mobile: mobile, source: "signup");
      _captureOtpRequestId(res);

      final ok = (res is Map && res["success"] == true);
      if (ok) {
        notifyListeners();
        return true;
      } else {
        _error = _friendlyMessage(
          (res is Map ? (res["message"] ?? res["error"]) : null) ??
              "Signup failed",
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
  Future<bool> requestLoginOtp({String? email, String? mobile}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final normalizedEmail = (email ?? '').trim();
      final normalizedMobile = (mobile ?? '').trim();

      final payload = <String, dynamic>{
        if (normalizedEmail.isNotEmpty) "email": normalizedEmail,
        if (normalizedMobile.isNotEmpty) "mobileNumber": normalizedMobile,
        "source": "login",
      };

      if (payload["email"] == null && payload["mobileNumber"] == null) {
        _isLoading = false;
        _error = "Provide email or mobile to request OTP.";
        notifyListeners();
        return false;
      }

      debugPrint("📤 Request Login OTP: $payload");

      final res = await _apiService.postData(ApiEndPoints.login, payload);
      debugPrint("📥 Request Login OTP response: $res");

      _isLoading = false;

      setPendingIdentity(
        email: normalizedEmail.isNotEmpty ? normalizedEmail : null,
        mobile: normalizedMobile.isNotEmpty ? normalizedMobile : null,
        source: "login",
      );
      _captureOtpRequestId(res);

      final ok = (res is Map && res["success"] == true);
      if (ok) {
        notifyListeners();
        return true;
      } else {
        _error = _friendlyMessage(
          (res is Map ? (res["message"] ?? res["error"]) : null) ??
              "Failed to send OTP",
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
  Future<bool> verifyOtp({
    required String otp,
    String? email,
    String? mobile,
    String? source,
  }) async {
    _isLoading = true;
    _error = null;
    _isOtpVerified = false;
    notifyListeners();

    try {
      final normalizedOtp = _normalizeOtp(otp);
      final otpValue = RegExp(r'^\d+$').hasMatch(normalizedOtp)
          ? int.parse(normalizedOtp)
          : normalizedOtp;

      final effectiveEmail = (email ?? _pendingEmail)?.trim();
      final effectiveMobile = (mobile ?? _pendingMobile)?.trim();
      final effectiveSource = (source ?? _pendingSource)?.trim();
      final effectiveChannel =
          _otpChannel ??
          ((effectiveEmail?.isNotEmpty ?? false)
              ? "email"
              : (effectiveMobile?.isNotEmpty ?? false)
              ? "mobile"
              : null);

      final payload = <String, dynamic>{
        "otp": otpValue,
        if (effectiveEmail?.isNotEmpty == true) "email": effectiveEmail,
        if (effectiveMobile?.isNotEmpty == true)
          "mobileNumber": effectiveMobile,
        if (effectiveSource?.isNotEmpty == true) "source": effectiveSource,
        if (effectiveChannel != null) "channel": effectiveChannel,
        if (_otpRequestId != null && _otpRequestId!.isNotEmpty)
          "requestId": _otpRequestId,
      };

      debugPrint("📤 Verify OTP request: $payload");

      final res = await _apiService.postData(ApiEndPoints.verifyOtp, payload);
      debugPrint("📥 Verify OTP response: $res");

      _isLoading = false;

      final ok = (res is Map && res["success"] == true);
      if (ok) {
        _authToken =
            (res is Map ? (res["token"] ?? res["authToken"]) : null) ??
            ((res is Map && res["data"] is Map)
                ? (res["data"]["token"] ?? res["data"]["authToken"])
                : null);

        _isOtpVerified = true;
        notifyListeners();
        return true;
      } else {
        _error = _friendlyMessage(
          (res is Map ? (res["message"] ?? res["error"]) : null) ??
              "OTP verification failed",
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

  // ---------- NEW: SUBMIT PROFILE ----------
  /// Posts the "Introduce yourself" data.
  /// Expected payload sample:
  /// {
  ///   "name":"oliva Doe","age":30,"gender":"female","bio":"This is my bio",
  ///   "interests":["68d4f9dfdd3c0ef9b8ebbf19","68d4fac1dd3c0ef9b8ebbf20"],
  ///   "languages":["68d4fc53dd3c0ef9b8ebbf35","68d4fc69dd3c0ef9b8ebbf3a"]
  /// }
  Future<Profiledetails?> submitProfile({
    required String name,
    required int age,
    required String gender,
    required String bio,
    required List<String> interests,
    
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payload = {
        "name": name.trim(),
        "age": age,
        "gender": gender.trim().toLowerCase(),
        "bio": bio.trim(),       
        "interests": interests,
      };

      debugPrint("📤 Submit Profile payload: $payload");

      final res = await _apiService.postData(
        ApiEndPoints.profiledetails,
        payload,
      );

      debugPrint("📥 Submit Profile response: $res");

      _isLoading = false;

      final ok = (res is Map && res["success"] == true && res["data"] != null);
      if (ok) {
        final parsed = Profiledetails.fromJson(res);
        notifyListeners();
        return parsed;
      } else {
        _error = _friendlyMessage(
          (res is Map ? (res["message"] ?? res["error"]) : null) ??
              "Profile submission failed",
        );
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint("❌ Submit Profile exception: $_error");
      notifyListeners();
      return null;
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

  Future updateProfileDetails({
    required String name,
    required int age,
    required String gender,
    required String bio,
    required List<String> interestIds,
   

    String? photoUrl,
  }) async {}
}
