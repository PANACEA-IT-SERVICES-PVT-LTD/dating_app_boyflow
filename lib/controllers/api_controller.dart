import 'dart:convert';
import 'dart:io';

import 'package:Boy_flow/api_service/api_endpoint.dart';
import 'package:Boy_flow/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import '../utils/token_helper.dart';
import 'package:http/http.dart' as http;
import '../models/wallet_transaction.dart';

class ApiController extends ChangeNotifier {
  // Wallet transaction history state
  bool _isWalletTransactionLoading = false;
  String? _walletTransactionError;
  List<WalletTransaction> _walletTransactions = [];

  bool get isWalletTransactionLoading => _isWalletTransactionLoading;
  String? get walletTransactionError => _walletTransactionError;
  List<WalletTransaction> get walletTransactions =>
      List.unmodifiable(_walletTransactions);

  /// Fetch male user's wallet transactions with proper error handling
  Future<void> fetchWalletTransactions() async {
    if (_isWalletTransactionLoading) return; // Prevent duplicate calls
    _isWalletTransactionLoading = true;
    _walletTransactionError = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    try {
      print('[WALLET TRANSACTIONS] Starting fetch...');
      final apiService = ApiService();
      final transactionData = await apiService.fetchWalletTransactions();

      print(
        '[WALLET TRANSACTIONS] Received ${transactionData.length} transactions',
      );

      _walletTransactions =
          transactionData
              .map((json) => WalletTransaction.fromJson(json))
              .toList()
            ..sort(
              (a, b) => b.createdAt.compareTo(a.createdAt),
            ); // Sort by createdAt descending

      _walletTransactionError = null;
      print(
        '[WALLET TRANSACTIONS] Successfully loaded ${_walletTransactions.length} transactions',
      );
    } on Exception catch (e) {
      print('[WALLET TRANSACTIONS] Error: $e');
      _walletTransactions = [];
      _walletTransactionError = e.toString();
    } catch (e) {
      print('[WALLET TRANSACTIONS] Unexpected error: $e');
      _walletTransactions = [];
      _walletTransactionError = 'An unexpected error occurred: $e';
    } finally {
      _isWalletTransactionLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  // Transaction history state
  bool _isTransactionLoading = false;
  String? _transactionError;
  List<Map<String, dynamic>> _coinTransactions = [];

  bool get isTransactionLoading => _isTransactionLoading;
  String? get transactionError => _transactionError;
  List<Map<String, dynamic>> get coinTransactions =>
      List.unmodifiable(_coinTransactions);

  /// Fetch male user's coin transactions (sorted by createdAt desc)
  Future<void> fetchMaleCoinTransactions() async {
    if (_isTransactionLoading) return; // Prevent duplicate calls
    _isTransactionLoading = true;
    _transactionError = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    try {
      final result = await _apiService.fetchMaleCoinTransactions();
      if (result['success'] == true && result['data'] is List) {
        final List<dynamic> data = result['data'];
        // Sort by createdAt descending
        data.sort(
          (a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''),
        );
        _coinTransactions = data
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        _coinTransactions = [];
        _transactionError = 'No transactions found.';
      }
    } catch (e) {
      _coinTransactions = [];
      _transactionError = e.toString();
    } finally {
      _isTransactionLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  /// End an active call (audio or video)
  Future<Map<String, dynamic>> endCall({
    required String receiverId,
    required int duration,
    required String callType,
    required String callId,
  }) async {
    return await _apiService.endCall(
      receiverId: receiverId,
      duration: duration,
      callType: callType,
      callId: callId,
    );
  }

  final ApiService _apiService = ApiService();

  // Start a call (audio or video) - Returns CallCredentials model
  Future<Map<String, dynamic>> startCall({
    required String receiverId,
    required String callType,
  }) async {
    return await _apiService.startCall(
      receiverId: receiverId,
      callType: callType,
    );
  }

  // Check call status
  Future<Map<String, dynamic>> checkCallStatus({required String callId}) async {
    return await _apiService.checkCallStatus(callId: callId);
  }

  // Public getter to access the ApiService instance
  ApiService get apiService => _apiService;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _signupResponse;
  String? _authToken;
  bool _isOtpVerified = false;

  // female profiles cache
  List<Map<String, dynamic>> _femaleProfiles = [];

  // Remember identity + context for OTP verify
  String? _otpIdentity;
  String? _otpContext;

  // Sent follow requests cache
  List<Map<String, dynamic>> _sentFollowRequests = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get signupResponse => _signupResponse;
  String? get authToken => _authToken;
  bool get isOtpVerified => _isOtpVerified;

  /// Getter for female profiles cached in controller
  List<Map<String, dynamic>> get femaleProfiles =>
      List<Map<String, dynamic>>.unmodifiable(_femaleProfiles);

  List<Map<String, dynamic>> get sentFollowRequests =>
      List<Map<String, dynamic>>.unmodifiable(_sentFollowRequests);

  // Fetch all dropdown options from profile-and-image endpoint
  Future<Map<String, dynamic>> fetchProfileAndImageOptions() async {
    return await _apiService.fetchProfileAndImageOptions();
  }

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

  /// Fetches female profiles from the API and stores them in controller.
  /// Returns a List<Map<String, dynamic>> on success, throws on failure.
  Future<List<Map<String, dynamic>>> fetchBrowseFemales({
    int page = 1,
    int limit = 10,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

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

  /// Verifies OTP and saves token if present.
  Future<bool> verifyOtp(String otp, {String source = 'signup'}) async {
    final endpoint = source == 'login'
        ? ApiEndPoints.loginotpMale
        : ApiEndPoints.verifyOtpMale;
    final url = Uri.parse("${ApiEndPoints.baseUrl}$endpoint");
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

  /// Fetches female profiles for a specific dashboard section (e.g., 'new', 'all')
  Future<List<Map<String, dynamic>>> fetchDashboardSectionFemales({
    String section = 'all',
    int page = 1,
    int limit = 10,
    double? latitude,
    double? longitude,
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
      final dynamic res = await _apiService.fetchDashboardSectionFemales(
        section: section,
        page: page,
        limit: limit,
        latitude: latitude,
        longitude: longitude,
      );
      debugPrint(
        "📥 fetchDashboardSectionFemales ($section) raw response: $res",
      );

      List<Map<String, dynamic>> _normalizeList(dynamic input) {
        if (input is List<Map<String, dynamic>>) return input;
        if (input is List) {
          return input
              .where((e) => e != null)
              .map((e) {
                if (e is Map) return Map<String, dynamic>.from(e);
                try {
                  if (e is String) return {'name': e};
                  if (e is int || e is double) return {'value': e};
                  if (e is List) return {'list': e};
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
            mapInput['data'],
            mapInput['docs'],
          ];
          for (final c in candidates) {
            if (c is List) {
              return _normalizeList(c);
            }
          }
        }
        return <Map<String, dynamic>>[];
      }

      dynamic rawData;
      if (res is Map) {
        // Try to find a list of profiles in the most likely places
        if (res['data'] != null &&
            res['data'] is Map &&
            res['data']['results'] is List) {
          rawData = res['data']['results'];
        } else if (res['data'] != null && res['data'] is List) {
          rawData = res['data'];
        } else if (res['results'] != null && res['results'] is List) {
          rawData = res['results'];
        } else if (res['data'] != null &&
            res['data'] is Map &&
            res['data']['results'] is List) {
          rawData = res['data']['results'];
        } else if (res['data'] != null &&
            res['data'] is Map &&
            res['data']['results'] == null &&
            res['data'].isNotEmpty) {
          // If data exists but no results, try to find any list in data
          final dataMap = res['data'] as Map;
          final listInData = dataMap.values.firstWhere(
            (v) => v is List,
            orElse: () => null,
          );
          rawData = listInData ?? [];
        } else if (res['docs'] != null && res['docs'] is List) {
          rawData = res['docs'];
        } else if (res['items'] != null && res['items'] is List) {
          rawData = res['items'];
        } else if (res['list'] != null && res['list'] is List) {
          rawData = res['list'];
        } else {
          rawData = [];
        }
      } else {
        try {
          final jsonForm = (res as dynamic).toJson();
          if (jsonForm is Map) {
            if (jsonForm['data'] != null &&
                jsonForm['data']['results'] != null) {
              rawData = jsonForm['data']['results'];
            } else {
              rawData =
                  jsonForm['data'] ??
                  jsonForm['docs'] ??
                  jsonForm['items'] ??
                  jsonForm['list'] ??
                  jsonForm['results'] ??
                  jsonForm;
            }
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
      // Inject fallback demo profiles for 'follow' and 'new' if API returns empty
      // ...existing code...
      _femaleProfiles = normalizedProfiles;
      debugPrint('[DEBUG] _femaleProfiles set:');
      for (final p in _femaleProfiles) {
        debugPrint(p.toString());
      }
      _isLoading = false;
      if (WidgetsBinding.instance != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } else {
        notifyListeners();
      }
      return normalizedProfiles;
    } catch (e, st) {
      debugPrint(
        "❌ fetchDashboardSectionFemales ($section) exception: $e\n$st",
      );
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

  /// Set static profiles for demo purposes
  void setStaticProfiles(List<Map<String, dynamic>> profiles) {
    _femaleProfiles = profiles;
    _isLoading = false;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Fetch female users from dashboard with section, page and limit parameters
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
      final dynamic res = await _apiService.fetchFemaleUsersFromDashboard(
        section: section,
        page: page,
        limit: limit,
      );
      debugPrint(
        "📥 fetchFemaleUsersFromDashboard ($section) raw response: $res",
      );

      List<Map<String, dynamic>> _normalizeList(dynamic input) {
        if (input is List<Map<String, dynamic>>) return input;
        if (input is List) {
          return input
              .where((e) => e != null)
              .map((e) {
                if (e is Map) return Map<String, dynamic>.from(e);
                try {
                  if (e is String) return {'name': e};
                  if (e is int || e is double) return {'value': e};
                  if (e is List) return {'list': e};
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
            mapInput['data'],
            mapInput['docs'],
          ];
          for (final c in candidates) {
            if (c is List) {
              return _normalizeList(c);
            }
          }
        }
        return <Map<String, dynamic>>[];
      }

      dynamic rawData;
      if (res is Map) {
        if (res['data'] != null && res['data']['results'] != null) {
          // Handle new response structure: {data: {results: [...]}}
          rawData = res['data']['results'];
        } else if (res['data'] != null && res['data'] is List) {
          rawData = res['data'];
        } else if (res['results'] != null && res['results'] is List) {
          rawData = res['results'];
        } else if (res['data'] != null &&
            res['data'] is Map &&
            res['data']['results'] is List) {
          rawData = res['data']['results'];
        } else if (res['data'] != null &&
            res['data'] is Map &&
            res['data']['results'] == null &&
            res['data'].isNotEmpty) {
          // If data exists but no results, try to find any list in data
          final dataMap = res['data'] as Map;
          final listInData = dataMap.values.firstWhere(
            (v) => v is List,
            orElse: () => null,
          );
          rawData = listInData ?? [];
        } else if (res['docs'] != null && res['docs'] is List) {
          rawData = res['docs'];
        } else if (res['items'] != null && res['items'] is List) {
          rawData = res['items'];
        } else if (res['list'] != null && res['list'] is List) {
          rawData = res['list'];
        } else {
          rawData = [];
        }
      } else {
        try {
          final jsonForm = (res as dynamic).toJson();
          if (jsonForm is Map) {
            // Check for new structure first
            if (jsonForm['data'] != null &&
                jsonForm['data']['results'] != null) {
              rawData = jsonForm['data']['results'];
            } else {
              rawData =
                  jsonForm['data'] ??
                  jsonForm['docs'] ??
                  jsonForm['items'] ??
                  jsonForm['list'] ??
                  jsonForm['results'] ??
                  jsonForm;
            }
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
    } catch (e, st) {
      debugPrint(
        "❌ fetchFemaleUsersFromDashboard ($section) exception: $e\n$st",
      );
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

  /// Fetch followed female users
  Future<List<Map<String, dynamic>>> fetchFollowedFemales({
    int page = 1,
    int limit = 10,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final result = await _apiService.fetchFollowedFemales(
        page: page,
        limit: limit,
      );

      debugPrint("📥 fetchFollowedFemales raw response: $result");

      List<Map<String, dynamic>> _normalizeList(dynamic input) {
        if (input is List<Map<String, dynamic>>) return input;
        if (input is List) {
          return input
              .where((e) => e != null)
              .map((e) {
                if (e is Map) return Map<String, dynamic>.from(e);
                try {
                  if (e is String) return {'name': e};
                  if (e is int || e is double) return {'value': e};
                  if (e is List) return {'list': e};
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
            mapInput['data'],
            mapInput['docs'],
          ];
          for (final c in candidates) {
            if (c is List) {
              return _normalizeList(c);
            }
          }
        }
        return <Map<String, dynamic>>[];
      }

      dynamic rawData;
      if (result is Map) {
        if (result['data'] != null && result['data']['results'] != null) {
          // Handle new response structure: {data: {results: [...]}},
          rawData = result['data']['results'];
        } else if (result['data'] != null) {
          rawData = result['data'];
        } else if (result['docs'] != null) {
          rawData = result['docs'];
        } else if (result['items'] != null) {
          rawData = result['items'];
        } else if (result['list'] != null) {
          rawData = result['list'];
        } else if (result['results'] != null) {
          rawData = result['results'];
        } else {
          rawData = result;
        }
      } else {
        try {
          final jsonForm = (result as dynamic).toJson();
          if (jsonForm is Map) {
            // Check for new structure first
            if (jsonForm['data'] != null &&
                jsonForm['data']['results'] != null) {
              rawData = jsonForm['data']['results'];
            } else {
              rawData =
                  jsonForm['data'] ??
                  jsonForm['docs'] ??
                  jsonForm['items'] ??
                  jsonForm['list'] ??
                  jsonForm['results'] ??
                  jsonForm;
            }
          } else if (jsonForm is List) {
            rawData = jsonForm;
          } else {
            rawData = result;
          }
        } catch (_) {
          rawData = result;
        }
      }

      List<Map<String, dynamic>> normalizedProfiles = _normalizeList(rawData);

      _femaleProfiles = normalizedProfiles;
      _isLoading = false;
      _error = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      return normalizedProfiles;
    } catch (e, st) {
      debugPrint("❌ fetchFollowedFemales exception: $e\n$st");
      _femaleProfiles = [];
      _isLoading = false;
      _error = e.toString();
      _handleTokenError(e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      rethrow;
    }
  }

  // Fetch call history
  Future<Map<String, dynamic>> fetchCallHistory({
    int limit = 10,
    int skip = 0,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final result = await _apiService.fetchCallHistory(
        limit: limit,
        skip: skip,
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

  // Fetch call statistics
  Future<Map<String, dynamic>> fetchCallStats() async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final result = await _apiService.fetchCallStats();
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
}

/// Small utility widget for gradient text (kept in case you want it later).
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const GradientText(
    this.text, {
    required this.gradient,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}
