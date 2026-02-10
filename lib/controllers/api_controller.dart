import 'dart:convert';
import 'dart:io';

import 'package:Boy_flow/api_service/api_endpoint.dart';
import 'package:Boy_flow/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import '../utils/token_helper.dart';
import '../utils/otp_toast_util.dart'; // Import OTP toast utility
import 'package:http/http.dart' as http;
import '../models/wallet_transaction.dart';
import 'package:geolocator/geolocator.dart';

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

  final ApiService _apiService = ApiService();

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

  List<Map<String, dynamic>> _followers = [];
  List<Map<String, dynamic>> _following = [];

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

  List<Map<String, dynamic>> get followers => List<Map<String, dynamic>>.unmodifiable(_followers);
  List<Map<String, dynamic>> get following => List<Map<String, dynamic>>.unmodifiable(_following);

  // Method to manually refresh profiles if they disappear
  Future<void> refreshProfiles() async {
    if (_femaleProfiles.isEmpty) {
      debugPrint('[DEBUG] Profiles are empty, attempting to refresh...');
      await fetchDashboardSectionFemales(section: 'all', page: 1, limit: 20);
    }
  }

  // Fetch all dropdown options from profile-and-image endpoint
  Future<Map<String, dynamic>> fetchProfileAndImageOptions() async {
    return await _apiService.fetchProfileAndImageOptions();
  }

  // Fetch male user profile (GET /male-user/me)
  Future<Map<String, dynamic>> fetchMaleMe() async {
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
      final result = await _apiService.fetchMaleMe();
      _isLoading = false;
      if (WidgetsBinding.instance != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } else {
        notifyListeners();
      }
      return result;
    } catch (e) {
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

  /// Fetch followers of the male user
  Future<List<Map<String, dynamic>>> fetchFollowers() async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final res = await _apiService.fetchFollowers();
      _followers = res;
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

  /// Fetch following users of the male user
  Future<List<Map<String, dynamic>>> fetchFollowing() async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final res = await _apiService.fetchFollowing();
      _following = res;
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
      // Refresh sent follow requests to update UI state
      await fetchSentFollowRequests();
      
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

  /// Cancel follow request for a female user
  Future<Map<String, dynamic>> cancelFollowRequest(String femaleUserId) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.cancelFollowRequest(
        femaleUserId: femaleUserId,
      );
      // Refresh sent follow requests to update UI state
      await fetchSentFollowRequests();
      
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

  /// Unfollow a female user
  Future<Map<String, dynamic>> unfollowUser(String femaleUserId) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.unfollowUser(
        femaleUserId: femaleUserId,
      );
      // Logic for unfollow might require refreshing following list if you maintain one
      // For now, if following status is tracked via sent follow requests, refresh it
      await fetchSentFollowRequests();
      
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

  /// Get follow status for a user: 'none', 'pending', 'following'
  String getFollowStatus(String femaleUserId) {
    // Check if there's a pending request
    final isPending = _sentFollowRequests.any((req) => 
      (req['femaleUserId'] is Map ? req['femaleUserId']['_id'] : req['femaleUserId']) == femaleUserId &&
      req['status'] == 'pending'
    );
    if (isPending) return 'pending';

    // Check if already following (this depends on backend logic, 
    // usually active follow requests have status 'accepted' or similar)
    final isFollowing = _sentFollowRequests.any((req) => 
      (req['femaleUserId'] is Map ? req['femaleUserId']['_id'] : req['femaleUserId']) == femaleUserId &&
      req['status'] == 'accepted'
    );
    if (isFollowing) return 'following';

    return 'none';
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

  // Fetch followed female users
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
      final List<Map<String, dynamic>> res = await _apiService.fetchFollowedFemales(
        page: page,
        limit: limit,
      );
      
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
      // If it fails, return empty list or rethrow? 
      // Existing code might expect rethrow. But typically for lists we might return empty.
      // Let's rethrow to be safe and consistent with previous behavior if any.
      rethrow; 
    }
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

      // Filter for online users only
      List<Map<String, dynamic>> onlineProfiles = normalizedProfiles.where((
        profile,
      ) {
        // Check if profile has online status field
        bool isOnline =
            profile['isOnline'] == true ||
            profile['online'] == true ||
            profile['status'] == 'online';

        // If no online field exists, assume all profiles are online for now
        // You can modify this logic based on your API response structure
        return isOnline || !profile.containsKey('isOnline');
      }).toList();

      debugPrint(
        '[DEBUG] Found ${normalizedProfiles.length} total profiles, ${onlineProfiles.length} online profiles',
      );

      // Only update _femaleProfiles if this is the 'all' section to prevent overwriting
      if (section == 'all') {
        debugPrint(
          '[DEBUG] Setting _femaleProfiles with ${onlineProfiles.length} ONLINE items for ALL section',
        );
        _femaleProfiles = onlineProfiles;
      } else {
        debugPrint(
          '[DEBUG] Fetched ${onlineProfiles.length} ONLINE profiles for $section section, but keeping _femaleProfiles unchanged',
        );
      }

      debugPrint('[DEBUG] _femaleProfiles set:');
      for (final p in _femaleProfiles) {
        debugPrint(p.toString());
      }
      debugPrint('[DEBUG] _femaleProfiles hash: ${_femaleProfiles.hashCode}');

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
      debugPrint(
        '[DEBUG] ERROR occurred but NOT clearing _femaleProfiles to prevent disappearance: $e',
      );
      // Keep existing profiles instead of clearing them
      // _femaleProfiles = [];
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

  /// Update specific profile details using PATCH /male-user/profile-details
  Future<Map<String, dynamic>> updateProfileDetails({
    required Map<String, dynamic> data,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.updateProfileDetails(data: data);
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


  // Update profile and image with geolocation
  Future<Map<String, dynamic>> updateProfileAndImage({
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      // Get current location
      try {
        Position position = await _determinePosition();
        fields['latitude'] = position.latitude.toString();
        fields['longitude'] = position.longitude.toString();
      } catch (e) {
        print('Error getting location: $e');
        // Proceed without location if it fails, or handle as needed
        // For now, we'll just log it and proceed
      }

      final result = await _apiService.updateProfileAndImage(
        fields: fields,
        imageFile: imageFile,
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

  // Helper to determine position
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Delete account permanently
  Future<Map<String, dynamic>> deleteAccount() async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    try {
      final result = await _apiService.deleteAccount();
      
      // Clear token after successful deletion
      try {
        await saveLoginToken('');
      } catch (_) {}
      _authToken = null;
      
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
