import 'dart:convert';

import 'package:Boy_flow/api_service/api_endpoint.dart';
import 'package:Boy_flow/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../utils/token_helper.dart';
import 'package:http/http.dart' as http;

class ApiController extends ChangeNotifier {
  // Sent follow requests cache
  List<Map<String, dynamic>> _sentFollowRequests = [];
  List<Map<String, dynamic>> get sentFollowRequests =>
      List<Map<String, dynamic>>.unmodifiable(_sentFollowRequests);

  // Fetch sent follow requests and store in controller
  Future<List<Map<String, dynamic>>> fetchSentFollowRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _apiService.fetchSentFollowRequests();
      _sentFollowRequests = res;
      _isLoading = false;
      notifyListeners();
      return res;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Send follow request for a female user
  Future<Map<String, dynamic>> sendFollowRequest(String femaleUserId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _apiService.sendFollowRequest(
        femaleUserId: femaleUserId,
      );
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _signupResponse;
  String? _authToken;
  bool _isOtpVerified = false;

  // female profiles cache
  List<Map<String, dynamic>> _femaleProfiles = [];

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

  /// Getter for female profiles cached in controller
  List<Map<String, dynamic>> get femaleProfiles =>
      List<Map<String, dynamic>>.unmodifiable(_femaleProfiles);

  /// Verifies OTP and saves token if present.
  Future<bool> verifyOtp(String otp, {String source = 'signup'}) async {
    final endpoint = source == 'login'
        ? ApiEndPoints.loginotpMale
        : ApiEndPoints.verifyOtpMale;
    final url = Uri.parse("${ApiEndPoints.baseUrls}$endpoint");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"otp": otp}),
    );
    final body = jsonDecode(response.body);
    final success = body['success'] == true;
    if (success) {
      final token = body['token'] ?? body['access_token'];
      if (token != null && token is String && token.isNotEmpty) {
        _authToken = token;
        // Save to SharedPreferences for later use
        try {
          await saveLoginToken(token);
        } catch (_) {}
      }
    }
    return success;
  }

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
    final List<String> candidates = [
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

  /// Fetches female profiles from the API and stores them in controller.
  /// Returns a List<Map<String, dynamic>> on success, throws on failure.
  Future<List<Map<String, dynamic>>> fetchBrowseFemales({
    int page = 1,
    int limit = 10,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Call service (expected to return a typed model or Map/List)
      final dynamic res = await _apiService.fetchFemaleUsers(
        page: page,
        limit: limit,
      );

      debugPrint("📥 fetchBrowseFemales raw response: $res");

      // Helper: convert many shapes into List<Map<String,dynamic>>
      List<Map<String, dynamic>> _normalizeList(dynamic input) {
        if (input == null) return <Map<String, dynamic>>[];

        // If it's already a List, try to convert each element to Map
        if (input is List) {
          return input
              .where((e) => e != null)
              .map((e) {
                if (e is Map) return Map<String, dynamic>.from(e);
                // If it's a model object, try to call toJson()
                try {
                  final jsonLike = (e as dynamic).toJson();
                  if (jsonLike is Map)
                    return Map<String, dynamic>.from(jsonLike);
                } catch (_) {}
                return <String, dynamic>{};
              })
              .where((m) => m.isNotEmpty)
              .toList();
        }

        // If it's a Map, try to detect nested lists (common keys)
        if (input is Map) {
          final Map mapInput = input;
          final candidates = <dynamic>[
            mapInput['data'],
            mapInput['docs'],
            mapInput['items'],
            mapInput['list'],
            mapInput['results'],
          ];
          for (final c in candidates) {
            if (c is List) {
              return _normalizeList(c);
            }
          }
        }

        // If nothing matched, return empty
        return <Map<String, dynamic>>[];
      }

      // Determine raw data candidate(s) from `res`
      dynamic rawData;

      // If service returned a Map-like response
      if (res is Map) {
        // Common patterns: { success: true, data: [...] } or { data: { docs: [...] } }
        if (res['data'] != null) {
          rawData = res['data'];
        } else if (res['docs'] != null) {
          rawData = res['docs'];
        } else if (res['items'] != null) {
          rawData = res['items'];
        } else if (res['list'] != null) {
          rawData = res['list'];
        } else if (res['results'] != null) {
          rawData = res['results'];
        } else {
          // fallback: maybe the map itself is a single profile object
          rawData = res;
        }
      }
      // If service returned a typed model object that exposes toJson()
      else {
        try {
          final jsonForm = (res as dynamic).toJson();
          if (jsonForm is Map) {
            rawData =
                jsonForm['data'] ??
                jsonForm['docs'] ??
                jsonForm['items'] ??
                jsonForm['list'] ??
                jsonForm['results'] ??
                jsonForm;
          } else if (jsonForm is List) {
            rawData = jsonForm;
          } else {
            rawData = res;
          }
        } catch (_) {
          // not a model with toJson, use res directly
          rawData = res;
        }
      }

      // Normalize into a list
      List<Map<String, dynamic>> parsed = _normalizeList(rawData);

      // If parsed is empty, try alternative heuristics:
      if (parsed.isEmpty) {
        // 1) If `rawData` is a Map representing a single profile, wrap it
        if (rawData is Map) {
          final Map<String, dynamic> candidateMap = Map<String, dynamic>.from(
            rawData,
          );
          if (candidateMap.containsKey('name') ||
              candidateMap.containsKey('_id') ||
              candidateMap.containsKey('avatarUrl') ||
              candidateMap.containsKey('avatar')) {
            parsed = [candidateMap];
          }
        }

        // 2) If original `res` had any top-level List value, use the first one
        if (parsed.isEmpty && res is Map) {
          for (final v in res.values) {
            if (v is List) {
              parsed = _normalizeList(v);
              if (parsed.isNotEmpty) break;
            }
          }
        }

        // 3) As a last attempt, if res itself is a List-like model or toJson returned a List
        if (parsed.isEmpty) {
          try {
            final jsonForm = (res as dynamic).toJson();
            if (jsonForm is List) parsed = _normalizeList(jsonForm);
          } catch (_) {}
        }
      }

      // Success path
      if (parsed.isNotEmpty) {
        _femaleProfiles = parsed;
        _isLoading = false;
        _error = null;
        if (WidgetsBinding.instance != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        } else {
          notifyListeners();
        }
        return parsed;
      }

      // Failure path: build friendly message and throw
      String serverMessage = 'No profiles found';
      try {
        if (res is Map) {
          serverMessage =
              (res['message'] ?? res['error'] ?? res['msg'] ?? serverMessage)
                  .toString();
        } else {
          // try model's message fields if available
          final modelMsg =
              (res as dynamic).message ??
              (res as dynamic).error ??
              (res as dynamic).msg;
          if (modelMsg != null) serverMessage = modelMsg.toString();
        }
      } catch (_) {}

      _femaleProfiles = [];
      _isLoading = false;
      _error = _friendlyMessage(serverMessage);
      notifyListeners();
      throw Exception(_error);
    } catch (e, st) {
      debugPrint("❌ fetchBrowseFemales exception: $e\n$st");
      _femaleProfiles = [];
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  String _friendlyMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains("expired")) {
      return "Your OTP has expired. Please request a new one.";
    }
    if (lower.contains("invalid")) {
      return "Invalid OTP. Please try again.";
    }
    if (lower.contains("duplicate")) {
      return "This email or phone is already registered.";
    }
    if (lower.contains("not found")) {
      return "We couldn't find an account with that email.";
    }
    if (lower.contains("timeout")) {
      return "Request timed out. Check your connection and try again.";
    }
    if (lower.contains("network")) {
      return "Network error. Please check your internet connection.";
    }
    return message;
  }
}
