import 'dart:convert';
import 'dart:io';

import 'package:Boy_flow/api_service/api_endpoint.dart';
import 'package:Boy_flow/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../utils/token_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiController extends ChangeNotifier {
  // Fetch male user profile (GET /male-user/me)
  Future<Map<String, dynamic>> fetchMaleMe() async {
    return await _apiService.fetchMaleMe();
  }

  // Fetch all available sports
  Future<List<String>> fetchAllSports() async {
    return await _apiService.fetchAllSports();
  }

  // Fetch all available film
  Future<List<String>> fetchAllFilm() async {
    return await _apiService.fetchAllFilm();
  }

  // Fetch all available music
  Future<List<String>> fetchAllMusic() async {
    return await _apiService.fetchAllMusic();
  }

  // Fetch all available travel
  Future<List<String>> fetchAllTravel() async {
    return await _apiService.fetchAllTravel();
  }

  /// Upload image for male user
  Future<Map<String, dynamic>> uploadUserImage({
    required File imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.uploadUserImage(imageFile: imageFile);
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  /// Update travel preferences for male user
  Future<Map<String, dynamic>> updateUserTravel({
    required List<String> travel,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.updateUserTravel(travel: travel);
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  /// Update music preferences for male user
  Future<Map<String, dynamic>> updateUserMusic({
    required List<String> music,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.updateUserMusic(music: music);
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  /// Update film preferences for male user
  Future<Map<String, dynamic>> updateUserFilm({
    required List<String> film,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.updateUserFilm(film: film);
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  /// Update sports for male user
  Future<Map<String, dynamic>> updateUserSports({
    required List<String> sports,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.updateUserSports(sports: sports);
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  /// Callback to be set by UI to handle forced logout (e.g., redirect to login)
  VoidCallback? onForceLogout;

  // Handle token errors: clear token and notify UI for forced logout
  Future<void> _handleTokenError(Object e) async {
    final msg = e.toString().toLowerCase();
    if (msg.contains('no valid token') || msg.contains('please log in again')) {
      // Clear token from storage
      try {
        await saveLoginToken('');
      } catch (_) {}
      _authToken = null;
      // Notify UI to redirect to login if callback is set
      if (onForceLogout != null) {
        onForceLogout!();
      }
    }
  }

  /// Update user profile using PATCH API
  Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> fields,
    List<http.MultipartFile>? images,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.updateUserProfile(
        fields: fields,
        images: images,
      );
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  // Sent follow requests cache
  List<Map<String, dynamic>> _sentFollowRequests = [];
  List<Map<String, dynamic>> get sentFollowRequests =>
      List<Map<String, dynamic>>.unmodifiable(_sentFollowRequests);

  // Fetch sent follow requests and store in controller
  Future<List<Map<String, dynamic>>> fetchSentFollowRequests() async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final res = await _apiService.fetchSentFollowRequests();
      _sentFollowRequests = res;
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return res;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  /// Send follow request for a female user
  Future<Map<String, dynamic>> sendFollowRequest(String femaleUserId) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.sendFollowRequest(
        femaleUserId: femaleUserId,
      );
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  /// Register new male user
  Future<Map<String, dynamic>> registerMaleUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.registerMaleUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        referralCode: referralCode,
      );
      _isLoading = false;
      _signupResponse = result;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  final ApiService _apiService = ApiService();

  // Public getter to access the api service
  ApiService get apiService => _apiService;

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
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }

    try {
      // Call service (expected to return a typed model or Map/List)
      final dynamic res = await _apiService.fetchFemaleUsers(
        page: page,
        limit: limit,
      );

      debugPrint("📥 fetchBrowseFemales raw response: $res");

      List<Map<String, dynamic>> _normalizeList(dynamic input) {
        if (input is List<Map<String, dynamic>>) return input;
        if (input is List) {
          return input
              .where((e) => e != null)
              .map((e) {
                if (e is Map) return Map<String, dynamic>.from(e);
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
        if (input is Map) {
          final mapInput = Map<String, dynamic>.from(input);
          final candidates = [
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
        return <Map<String, dynamic>>[];
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      dynamic rawData;
      if (res is Map) {
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
          rawData = res;
        }
      } else {
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
          rawData = res;
        }
      }

      List<Map<String, dynamic>> normalizedProfiles = _normalizeList(rawData);

      if (normalizedProfiles.isEmpty) {
        if (rawData is Map) {
          final Map<String, dynamic> candidateMap = Map<String, dynamic>.from(
            rawData,
          );
          if (candidateMap.containsKey('name') ||
              candidateMap.containsKey('_id') ||
              candidateMap.containsKey('avatarUrl') ||
              candidateMap.containsKey('avatar')) {
            normalizedProfiles = [candidateMap];
          }
        }
        if (normalizedProfiles.isEmpty && res is Map) {
          for (final v in res.values) {
            if (v is List) {
              normalizedProfiles = _normalizeList(v);
              if (normalizedProfiles.isNotEmpty) break;
            }
          }
        }
        if (normalizedProfiles.isEmpty) {
          try {
            final jsonForm = (res as dynamic).toJson();
            if (jsonForm is List) normalizedProfiles = _normalizeList(jsonForm);
          } catch (_) {}
        }
      }

      if (normalizedProfiles.isNotEmpty) {
        _femaleProfiles = normalizedProfiles;
        _isLoading = false;
        _error = null;
        if (WidgetsBinding.instance != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        } else {
          notifyListeners();
        }
        return normalizedProfiles;
      }

      if (normalizedProfiles.isEmpty) {
        _femaleProfiles = [];
        _isLoading = false;
        _error = null;
        if (WidgetsBinding.instance != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        } else {
          notifyListeners();
        }
        return [];
      }

      String serverMessage = 'No profiles found';
      try {
        if (res is Map) {
          serverMessage =
              (res['message'] ?? res['error'] ?? res['msg'] ?? serverMessage)
                  .toString();
        } else {
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
      if (WidgetsBinding.instance != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } else {
        notifyListeners();
      }
      throw Exception(_error);
    } catch (e, st) {
      debugPrint("❌ fetchBrowseFemales exception: $e\n$st");
      _femaleProfiles = [];
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      if (WidgetsBinding.instance != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } else {
        notifyListeners();
      }
      rethrow;
    }
  }

  /// Fetches female profiles from the dashboard API and stores them in controller.
  /// Returns a List<Map<String, dynamic>> on success, throws on failure.
  Future<List<Map<String, dynamic>>> fetchFemaleUsersFromDashboard({
    String section = 'all',
    int page = 1,
    int limit = 10,
  }) async {
    _isLoading = true;
    _error = null;
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }

    try {
      // Call service to fetch from dashboard
      final dynamic res = await _apiService.fetchFemaleUsersFromDashboard(
        section: section,
        page: page,
        limit: limit,
      );

      debugPrint("📥 fetchFemaleUsersFromDashboard raw response: $res");

      List<Map<String, dynamic>> _normalizeList(dynamic input) {
        if (input is List<Map<String, dynamic>>) return input;
        if (input is List) {
          return input
              .where((e) => e != null)
              .map((e) {
                if (e is Map) return Map<String, dynamic>.from(e);
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
        if (input is Map) {
          final mapInput = Map<String, dynamic>.from(input);
          final candidates = [
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
        return <Map<String, dynamic>>[];
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      dynamic rawData;
      if (res is Map) {
        if (res['data'] != null) {
          rawData = res['data'];
          // For the dashboard API, the actual results are in data.results
          if (rawData['results'] != null) {
            rawData = rawData['results'];
          }
        } else if (res['docs'] != null) {
          rawData = res['docs'];
        } else if (res['items'] != null) {
          rawData = res['items'];
        } else if (res['list'] != null) {
          rawData = res['list'];
        } else if (res['results'] != null) {
          rawData = res['results'];
        } else {
          rawData = res;
        }
      } else {
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
          rawData = res;
        }
      }

      List<Map<String, dynamic>> normalizedProfiles = _normalizeList(rawData);

      if (normalizedProfiles.isEmpty) {
        if (rawData is Map) {
          final Map<String, dynamic> candidateMap = Map<String, dynamic>.from(
            rawData,
          );
          if (candidateMap.containsKey('name') ||
              candidateMap.containsKey('_id') ||
              candidateMap.containsKey('avatarUrl') ||
              candidateMap.containsKey('avatar')) {
            normalizedProfiles = [candidateMap];
          }
        }
        if (normalizedProfiles.isEmpty && res is Map) {
          for (final v in res.values) {
            if (v is List) {
              normalizedProfiles = _normalizeList(v);
              if (normalizedProfiles.isNotEmpty) break;
            }
          }
        }
        if (normalizedProfiles.isEmpty) {
          try {
            final jsonForm = (res as dynamic).toJson();
            if (jsonForm is List) normalizedProfiles = _normalizeList(jsonForm);
          } catch (_) {}
        }
      }

      if (normalizedProfiles.isNotEmpty) {
        _femaleProfiles = normalizedProfiles;
        _isLoading = false;
        _error = null;
        if (WidgetsBinding.instance != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        } else {
          notifyListeners();
        }
        return normalizedProfiles;
      }

      if (normalizedProfiles.isEmpty) {
        _femaleProfiles = [];
        _isLoading = false;
        _error = null;
        if (WidgetsBinding.instance != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        } else {
          notifyListeners();
        }
        return [];
      }

      String serverMessage = 'No profiles found';
      try {
        if (res is Map) {
          serverMessage =
              (res['message'] ?? res['error'] ?? res['msg'] ?? serverMessage)
                  .toString();
        } else {
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
      if (WidgetsBinding.instance != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } else {
        notifyListeners();
      }
      throw Exception(_error);
    } catch (e, st) {
      debugPrint("❌ fetchFemaleUsersFromDashboard exception: $e\n$st");
      _femaleProfiles = [];
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      if (WidgetsBinding.instance != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } else {
        notifyListeners();
      }
      rethrow;
    }
  }

  /// Update specific profile details
  Future<Map<String, dynamic>> updateProfileDetails({
    String? firstName,
    String? lastName,
    String? height,
    String? religion,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      // Validate religion if provided
      if (religion != null && !_isValidObjectId(religion)) {
        throw Exception('Invalid religion ID format');
      }

      final result = await _apiService.updateProfileDetails(
        firstName: firstName,
        lastName: lastName,
        height: height,
        religion: religion,
        imageUrl: imageUrl,
      );
      _isLoading = false;
      _updateProfileResponse = result;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  Map<String, dynamic>? _updateProfileResponse;
  Map<String, dynamic>? get updateProfileResponse => _updateProfileResponse;

  /// Fetch current male user profile
  Future<Map<String, dynamic>> fetchCurrentMaleProfile() async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.fetchCurrentMaleProfile();
      _isLoading = false;
      _currentMaleProfile = result;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  /// Fetch male user profile and images
  Future<Map<String, dynamic>> fetchMaleProfileAndImage() async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.fetchMaleProfileAndImage();
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  Map<String, dynamic>? _currentMaleProfile;
  Map<String, dynamic>? get currentMaleProfile => _currentMaleProfile;

  // Check if a string is a valid MongoDB ObjectId (24-character hex string)
  bool _isValidObjectId(String id) {
    if (id.length != 24) return false;
    return RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id);
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

  // Block a female user
  Future<Map<String, dynamic>> blockUser({required String femaleUserId}) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.blockUser(femaleUserId: femaleUserId);
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  // Fetch blocked users list
  Future<Map<String, dynamic>> fetchBlockedUsersList({
    required String femaleUserId,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.fetchBlockedUsersList(
        femaleUserId: femaleUserId,
      );
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  // Unblock a female user
  Future<Map<String, dynamic>> unblockUser({
    required String femaleUserId,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.unblockUser(femaleUserId: femaleUserId);
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  // Clear authentication token
  Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    // Also clear any other auth-related data
    await prefs.remove('userProfile');
  }
}
