import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Added for MediaType
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/female_user.dart';
import '../api_service/api_endpoint.dart';
import '../utils/otp_toast_util.dart'; // Import OTP toast utility
import '../models/gift.dart';
import '../models/send_gift_response.dart';
import '../models/profile_model.dart';
import '../models/wallet_transaction.dart';

class ApiService {
  // Fetch male user's wallet transactions
  Future<Map<String, dynamic>> fetchMaleWalletTransactions() async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrls}/male-user/me/transactions?operationType=wallet',
    );
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch wallet transactions');
    }
  }

  Future<Map<String, dynamic>> fetchMaleCoinTransactions() async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrls}/male-user/me/transactions?operationType=coin',
    );
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // Handle 404 for no coin transactions found
      print('No coin transactions found (404) - returning empty list');
      return {
        'success': true,
        'data': [],
        'message': 'No coin transactions found',
      };
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch coin transactions');
    }
  }

  /// End an active call (audio or video)
  Future<Map<String, dynamic>> endCall({
    required String receiverId,
    required int duration,
    required String callType, // "audio" or "video"
    required String callId,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.endCall}');
    final headers = await _getHeaders();
    final body = json.encode({
      'receiverId': receiverId,
      'duration': duration,
      'callType': callType,
      'callId': callId,
    });
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to end call: ${response.body}');
    }
  }

  String? _authToken;
  final String baseUrl = ApiEndPoints.baseUrls;
  final Dio _dio = Dio();

  // Get auth token from shared preferences
  Future<void> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('token');
  }

  // Get headers with authorization
  Future<Map<String, String>> _getHeaders() async {
    await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  // Start a call (audio or video) - Updated to return credentials needed for Agora
  Future<Map<String, dynamic>> startCall({
    required String receiverId,
    required String callType, // "audio" or "video"
  }) async {
    final callUrl = ApiEndPoints.baseUrls + ApiEndPoints.startCall;
    print('CALL API URL => $callUrl');

    final headers = await _getHeaders();
    final body = json.encode({'receiverId': receiverId, 'callType': callType});

    final response = await http.post(
      Uri.parse(callUrl),
      headers: headers,
      body: body,
    );

    print('Start Call Response Status: ${response.statusCode}');
    print('Start Call Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      // Ensure the response includes the required credentials
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;

        // The backend should return these fields:
        // callId, channelName, agoraToken, receiverId, callType
        if (data['callId'] == null ||
            data['channelName'] == null ||
            data['agoraToken'] == null) {
          throw Exception('Missing required call credentials from backend');
        }

        return result;
      } else {
        throw Exception('Invalid response format from start call API');
      }
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to start call: ${response.body}');
    }
  }

  // Check call status
  Future<Map<String, dynamic>> checkCallStatus({required String callId}) async {
    final statusUrl =
        ApiEndPoints.baseUrls + ApiEndPoints.checkCallStatus + '/$callId/status';
    print('CHECK CALL STATUS URL => $statusUrl');

    final headers = await _getHeaders();

    final response = await http.get(Uri.parse(statusUrl), headers: headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to check call status: ${response.body}');
    }
  }

  // Handle API errors
  void _handleError(int statusCode, dynamic responseBody) {
    String message = 'Failed to load data';
    try {
      if (responseBody is String) {
        // Only try to decode JSON if the response body is not empty
        if (responseBody.isNotEmpty) {
          final jsonResponse = json.decode(responseBody);
          message = jsonResponse['message'] ?? jsonResponse['error'] ?? message;
          if (message.toLowerCase().contains('user not found')) {
            throw Exception(
              'Your session has expired or user does not exist. Please log in again.',
            );
          }
        } else {
          message = 'Empty response received (Status: $statusCode)';
        }
      } else if (responseBody != null) {
        message = responseBody.toString();
      }
    } catch (e) {
      // If JSON parsing fails, use the raw response body or status-based message
      message = responseBody.toString().isNotEmpty
          ? responseBody.toString()
          : 'HTTP Error: $statusCode';
    }

    if (statusCode == 404) {
      if (responseBody.toString().toLowerCase().contains('user') ||
          responseBody.toString().toLowerCase().contains('profile')) {
        message = 'User profile not found (404). Please log in again.';
      } else {
        message = 'Resource does not exist (404).';
      }
    } else if (statusCode == 401) {
      message = 'Unauthorized access (401). Please log in again.';
    } else if (statusCode == 500) {
      message = 'Internal server error (500). Please try again later.';
    } else if (statusCode == 0) {
      message =
          'Network error: Unable to connect to server. Please check your internet connection.';
    }

    throw Exception(message);
  }

  // Fetch dashboard profiles based on section
  Future<Map<String, dynamic>> fetchDashboardProfiles({
    required String section,
    int page = 1,
    int limit = 10,
    double? latitude,
    double? longitude,
  }) async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrls}${ApiEndPoints.dashboardEndpoint}',
    );
    final headers = await _getHeaders();

    // Construct request body
    final Map<String, dynamic> body = {
      'section': section,
      'page': page,
      'limit': limit,
    };

    // Add location if available (required for 'nearby' section)
    if (latitude != null && longitude != null) {
      body['location'] = {
        'latitude': latitude,
        'longitude': longitude,
      };
    }

    print('[DEBUG] fetchDashboardProfiles called with section: $section');
    print('[DEBUG] URL: $url');
    print('[DEBUG] Body: $body');

    try {
      // Changed from GET to POST as per API requirement
      final response = await http
          .post(url, headers: headers, body: json.encode(body))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('[ERROR] Request timed out after 10 seconds');
              return http.Response('', 408); // Return timeout response
            },
          );

      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          // Safely decode JSON
          final result = json.decode(response.body);
          
          // Check various possible response structures
          if (result is Map) {
            // Structure 1: { data: { results: [...] } }
            if (result.containsKey('data') &&
                result['data'] is Map &&
                result['data'].containsKey('results')) {
              final results = result['data']['results'];
              print('[DEBUG] Found results in data.results: ${results is List ? results.length : 'not a list'}');
              return result.cast<String, dynamic>();
            }
            // Structure 2: { data: [...] }
            else if (result.containsKey('data') && result['data'] is List) {
              return {
                'success': true,
                'data': {'results': result['data']},
              };
            }
            // Structure 3: { results: [...] }
            else if (result.containsKey('results') && result['results'] is List) {
              return {
                'success': true,
                'data': {'results': result['results']},
              };
            }
            // Unknown structure - log and return empty
            else {
              print('[WARNING] Unknown response structure. Available keys: ${result.keys.toList()}');
              return {
                'success': true,
                'data': {'results': []},
              };
            }
          } else {
            return {
              'success': false,
              'data': {'results': []},
            };
          }
        } catch (formatException) {
          print('[ERROR] JSON decode failed: $formatException');
          throw Exception('Failed to parse dashboard response: $formatException');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again');
      } else if (response.statusCode == 404) {
        print('[ERROR] Dashboard endpoint not found (404)');
        throw Exception('Dashboard endpoint not found');
      } else if (response.statusCode == 408) {
        throw Exception('Request timeout - please try again');
      } else {
        throw Exception('Failed to fetch dashboard profiles: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('[ERROR] Exception in fetchDashboardProfiles: $e');
      rethrow;
    }
  }

  // Fetch all dropdown options from profile-and-image endpoint
  Future<Map<String, dynamic>> fetchProfileAndImageOptions() async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrls}${ApiEndPoints.maleProfileAndImage}',
    );
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // Handle 404 for profile options not found
      print(
        'Profile and image options not found (404) - returning empty options',
      );
      return {
        'success': true,
        'data': {
          'sports': [],
          'films': [],
          'musics': [],
          'travels': [],
          'images': [],
        },
      };
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch profile and image options');
    }
  }

  // Fetch male user profile (GET /male-user/me)
  Future<Map<String, dynamic>> fetchMaleMe() async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}/male-user/me');
    final headers = await _getHeaders();

    // Log the request for debugging
    print('[DEBUG] Sending fetch male user profile request to: $url');
    print('[DEBUG] Request headers: $headers');

    final response = await http.get(url, headers: headers);

    // Log the response for debugging
    print(
      '[DEBUG] Fetch male user profile response status: ${response.statusCode}',
    );
    print('[DEBUG] Fetch male user profile response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // Handle 404 specifically for user profile not found
      print('User profile not found (404) - may need to complete registration');
      return {
        'success': false,
        'message': 'User profile not found. Please complete your registration.',
        'data': null,
      };
    } else if (response.statusCode == 500) {
      // Handle 500 server error specifically
      print('Server error (500) when fetching male user profile');
      try {
        final errorBody = json.decode(response.body);
        final serverMessage =
            errorBody['message'] ??
            errorBody['error'] ??
            'Internal server error';
        return {'success': false, 'message': serverMessage, 'data': null};
      } catch (e) {
        // If we can't parse the error response, return a generic 500 error
        return {
          'success': false,
          'message': 'Internal server error (500). Please try again later.',
          'data': null,
        };
      }
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch male user profile');
    }
  }

  // Fetch all available sports
  Future<List<String>> fetchAllSports() async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.maleSports}');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] is List) {
        return List<String>.from(
          (data['data'] as List).map((e) => e['name'].toString()),
        );
      }
      return [];
    } else if (response.statusCode == 404) {
      // Handle 404 for sports not found
      print('Sports data not found (404) - returning empty list');
      return [];
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch sports');
    }
  }

  // Fetch all available film
  Future<List<String>> fetchAllFilm() async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.maleFilm}');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] is List) {
        return List<String>.from(
          (data['data'] as List).map((e) => e['name'].toString()),
        );
      }
      return [];
    } else if (response.statusCode == 404) {
      // Handle 404 for films not found
      print('Film data not found (404) - returning empty list');
      return [];
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch film');
    }
  }

  // Fetch all available music
  Future<List<String>> fetchAllMusic() async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.maleMusic}');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] is List) {
        return List<String>.from(
          (data['data'] as List).map((e) => e['name'].toString()),
        );
      }
      return [];
    } else if (response.statusCode == 404) {
      // Handle 404 for music not found
      print('Music data not found (404) - returning empty list');
      return [];
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch music');
    }
  }

  // Fetch all available travel
  Future<List<String>> fetchAllTravel() async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.maleTravel}');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] is List) {
        return List<String>.from(
          (data['data'] as List).map((e) => e['name'].toString()),
        );
      }
      return [];
    } else if (response.statusCode == 404) {
      // Handle 404 for travel not found
      print('Travel data not found (404) - returning empty list');
      return [];
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch travel');
    }
  }

  // Upload image for male user
  Future<Map<String, dynamic>> uploadUserImage({
    required File imageFile,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}/male-user/upload-image');
    final headers = await _getHeaders();
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);
    request.files.add(
      await http.MultipartFile.fromPath('images', imageFile.path),
    );
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // Handle 404 for upload endpoint not found
      print('Upload endpoint not found (404)');
      return {
        'success': false,
        'message': 'Upload endpoint not found',
        'data': null,
      };
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to upload image');
    }
  }

  // Update travel preferences for male user
  Future<Map<String, dynamic>> updateUserTravel({
    required List<String> travel,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}/male-user/travel');
    final headers = await _getHeaders();
    final request = http.MultipartRequest('PATCH', url);
    request.headers.addAll(headers);
    request.fields['travel'] = jsonEncode(travel);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // Handle 404 for travel update endpoint not found
      print('Travel update endpoint not found (404)');
      return {
        'success': false,
        'message': 'Travel update endpoint not found',
        'data': null,
      };
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to update travel preferences');
    }
  }

  // Update music preferences for male user
  Future<Map<String, dynamic>> updateUserMusic({
    required List<String> music,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}/male-user/music');
    final headers = await _getHeaders();
    final request = http.MultipartRequest('PATCH', url);
    request.headers.addAll(headers);
    request.fields['music'] = jsonEncode(music);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // Handle 404 for music update endpoint not found
      print('Music update endpoint not found (404)');
      return {
        'success': false,
        'message': 'Music update endpoint not found',
        'data': null,
      };
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to update music preferences');
    }
  }

  // Update film preferences for male user
  Future<Map<String, dynamic>> updateUserFilm({
    required List<String> film,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}/male-user/film');
    final headers = await _getHeaders();
    final request = http.MultipartRequest('PATCH', url);
    request.headers.addAll(headers);
    request.fields['film'] = jsonEncode(film);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // Handle 404 for film update endpoint not found
      print('Film update endpoint not found (404)');
      return {
        'success': false,
        'message': 'Film update endpoint not found',
        'data': null,
      };
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to update film preferences');
    }
  }

  // Update sports for male user
  Future<Map<String, dynamic>> updateUserSports({
    required List<String> sports,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}/male-user/sports');
    final headers = await _getHeaders();
    final request = http.MultipartRequest('PATCH', url);
    request.headers.addAll(headers);
    request.fields['sports'] = jsonEncode(sports);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // Handle 404 for sports update endpoint not found
      print('Sports update endpoint not found (404)');
      return {
        'success': false,
        'message': 'Sports update endpoint not found',
        'data': null,
      };
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to update sports');
    }
  }

  // Login method (send OTP to user's email)
  Future<Map<String, dynamic>> login(String email) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.loginMale}');
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({"email": email.trim()});

    // Log the request for debugging
    print('[DEBUG] Sending login request to: $url');
    print('[DEBUG] Request headers: $headers');
    print('[DEBUG] Request body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Log the response for debugging
      print('[DEBUG] Login response status: ${response.statusCode}');
      print('[DEBUG] Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body;
      } else if (response.statusCode == 404) {
        // Handle 404 for login endpoint not found
        print('Login endpoint not found (404)');
        return {'success': false, 'message': 'User not found.', 'data': null};
      } else if (response.statusCode == 500) {
        // Handle 500 server error specifically
        print('Server error (500) when attempting login');
        try {
          final errorBody = json.decode(response.body);
          final serverMessage =
              errorBody['message'] ??
              errorBody['error'] ??
              'Internal server error';
          return {'success': false, 'message': serverMessage, 'data': null};
        } catch (e) {
          // If we can't parse the error response, return a generic 500 error
          return {
            'success': false,
            'message': 'Internal server error (500). Please try again later.',
            'data': null,
          };
        }
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to send login OTP: ${response.body}');
      }
    } on SocketException catch (e) {
      print('[ERROR] SocketException in login: $e');
      throw Exception(
        'Network error: Unable to connect to server. Please check your internet connection.',
      );
    } on http.ClientException catch (e) {
      print('[ERROR] ClientException in login: $e');
      throw Exception('Connection error occurred while trying to send OTP.');
    } on TimeoutException catch (e) {
      print('[ERROR] TimeoutException in login: Request timed out');
      throw Exception('Request timeout: Server is taking too long to respond.');
    } catch (e) {
      print('[ERROR] Unexpected error in login: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Update user profile (stub, implement as needed)
  Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> fields,
    List<http.MultipartFile>? images,
  }) async {
    // TODO: Implement actual update logic
    return {'success': true, 'message': 'Profile updated (stub)'};
  }

  // Update profile details using PATCH /male-user/profile-details
  Future<Map<String, dynamic>> updateProfileDetails({
    required Map<String, dynamic> data,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiEndPoints.baseUrls}${ApiEndPoints.maleProfileDetails}',
      );
      final headers = await _getHeaders();
      
      // Postman screenshot shows form-data being used for PATCH as well
      final request = http.MultipartRequest('PATCH', url);
      request.headers.addAll(headers);

      data.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to update profile details');
      }
    } catch (e) {
      throw Exception('Failed to update profile details: $e');
    }
  }

  // Fetch current male profile (stub, implement as needed)
  Future<Map<String, dynamic>> fetchCurrentMaleProfile() async {
    // TODO: Implement actual fetch logic
    return {'success': true, 'data': {}};
  }

  // Fetch sent follow requests
  Future<List<Map<String, dynamic>>> fetchSentFollowRequests() async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrls}${ApiEndPoints.maleFollowRequestsSent}',
    );
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final data = decoded['data'];
      if (data is List) {
        return data
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        return <Map<String, dynamic>>[];
      }
    } else if (response.statusCode == 404) {
      // Handle 404 for no follow requests found
      print('No sent follow requests found (404) - returning empty list');
      return <Map<String, dynamic>>[];
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch sent follow requests');
    }
  }

  // Fetch followers of the male user
  Future<List<Map<String, dynamic>>> fetchFollowers() async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.maleFollowers}');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final data = decoded['data'];
      if (data is List) {
        return data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch followers');
    }
  }

  // Fetch following users of the male user
  Future<List<Map<String, dynamic>>> fetchFollowing() async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.maleFollowing}');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final data = decoded['data'];
      if (data is List) {
        return data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch following');
    }
  }

  // Fetch chat messages for a specific chat room
  Future<Map<String, dynamic>> fetchChatMessages(String chatRoomId) async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrls}${ApiEndPoints.chatMessages}/$chatRoomId/messages',
    );
    final headers = await _getHeaders();
    
    print('[DEBUG] Fetching chat messages from: $url');
    
    final response = await http.get(url, headers: headers);
    
    print('[DEBUG] Chat messages response status: ${response.statusCode}');
    print('[DEBUG] Chat messages response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      print('Chat messages not found (404) - returning empty list');
      return {
        'success': true,
        'data': [],
        'message': 'No messages found',
      };
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch chat messages');
    }
  }

  // Upload chat media (image, video, audio)
  Future<Map<String, dynamic>> uploadChatMedia(File file, String type) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.chatUpload}');
    final headers = await _getHeaders();
    
    // Remove Content-Type header for multipart request as it is set automatically
    headers.remove('Content-Type');

    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);
    
    // Determine the type value expected by server strictly
    String typeValue = 'images'; // Default
    if (type.toLowerCase() == 'video') {
      typeValue = 'videos';
    } else if (type.toLowerCase() == 'audio') {
      typeValue = 'audio';
    } else if (type.toLowerCase() == 'image') {
      typeValue = 'images';
    }
    
    // Use 'file' as the field name as verified in Postman screenshot
    String fieldName = 'file';
    
    // Server requires 'type' field
    request.fields['type'] = typeValue;
    
    // Check extension for MediaType
    String ext = file.path.split('.').last.toLowerCase();
    String mimeType = 'image/jpeg';
    if (ext == 'png') mimeType = 'image/png';
    else if (ext == 'mp4') mimeType = 'video/mp4';
    else if (ext == 'aac' || ext == 'm4a' || ext == 'mp3') mimeType = 'audio/mpeg';

    // Add file with explicit MediaType
    request.files.add(await http.MultipartFile.fromPath(
      fieldName, 
      file.path,
      contentType: MediaType.parse(mimeType),
    ));
    
    print('[DEBUG] Uploading chat media ($type) to: $url using field: $fieldName, type: $typeValue');
    print('[DEBUG] Request files: ${request.files.map((f) => '${f.field}: ${f.filename}').toList()}');
    print('[DEBUG] Request fields: ${request.fields}');
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    print('[DEBUG] Upload response status: ${response.statusCode}');
    print('[DEBUG] Upload response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to upload chat media: ${response.body}');
    }
  }

  // Send chat message (text, emoji, or media URL)
  Future<Map<String, dynamic>> sendChatMessage({
    required String roomId,
    required String type, // "text", "image", "audio", "video", "emoji"
    required String content,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.chatSend}');
    final headers = await _getHeaders();
    final body = json.encode({
      'roomId': roomId,
      'chatRoomId': roomId, // Redundant key for compatibility
      'type': type,
      'content': content,
    });

    print('[DEBUG] Sending chat message to: $url');
    print('[DEBUG] Body: $body');

    final response = await http.post(url, headers: headers, body: body);

    print('[DEBUG] Send message response status: ${response.statusCode}');
    print('[DEBUG] Send message response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to send chat message');
    }
  }

  // Clear chat (DELETE /chat/room/:roomId/clear)
  Future<Map<String, dynamic>> clearChat({
    required String roomId,
    required List<String> messageIds,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.chatClear}/$roomId/clear');
    final headers = await _getHeaders();
    final body = jsonEncode({
      "roomId": roomId,
      "messageId": messageIds, // Required singular key for IDs array
    });

    print('[DEBUG] Clearing chat for room: $roomId');
    print('[DEBUG] URL: $url');
    print('[DEBUG] Body: $body');

    final request = http.Request('DELETE', url);
    request.headers.addAll(headers);
    request.body = body;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('[DEBUG] Clear chat response status: ${response.statusCode}');
    print('[DEBUG] Clear chat response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to clear chat: ${response.body}');
    }
  }

  // Delete message for self (DELETE /chat/message/:messageId)
  Future<Map<String, dynamic>> deleteMessage({
    required String messageId,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.chatMessage}/$messageId');
    final headers = await _getHeaders();

    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to delete message: ${response.body}');
    }
  }

  // Delete message for everyone (DELETE /chat/message/:messageId/delete-for-everyone)
  Future<Map<String, dynamic>> deleteMessageForEveryone({
    required String messageId,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.chatMessage}/$messageId/delete-for-everyone');
    final headers = await _getHeaders();

    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to delete message for everyone: ${response.body}');
    }
  }

  // Delete entire chat (DELETE /chat/room/:roomId)
  Future<Map<String, dynamic>> deleteChatRoom({
    required String roomId,
    required List<String> messageIds,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.chatRoom}/$roomId');
    final headers = await _getHeaders();
    final body = jsonEncode({
      "roomId": roomId,
      "messageId": messageIds,
    });

    // Use http.Request for DELETE with body
    final request = http.Request('DELETE', url);
    request.headers.addAll(headers);
    request.body = body;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to delete chat room: ${response.body}');
    }
  }

  // Mark as read (POST /chat/mark-as-read)
  Future<Map<String, dynamic>> markAsRead({
    required String roomId,
    required List<String> messageIds,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.chatMarkRead}');
    final headers = await _getHeaders();
    final body = jsonEncode({
      "roomId": roomId,
      "messageId": messageIds,
    });

    print('[DEBUG] Marking as read for room: $roomId');
    print('[DEBUG] Body: $body');

    final response = await http.post(url, headers: headers, body: body);

    print('[DEBUG] Mark as read response status: ${response.statusCode}');
    print('[DEBUG] Mark as read response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to mark as read: ${response.body}');
    }
  }

  // Toggle disappearing messages (POST /chat/:roomId/disappearing)
  Future<Map<String, dynamic>> toggleDisappearingMessages({
    required String roomId,
    required bool enabled,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.chatDisappearing}/$roomId/disappearing');
    final headers = await _getHeaders();
    final body = jsonEncode({
      "enabled": enabled
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to toggle disappearing messages: ${response.body}');
    }
  }

  // Block user (POST /male-user/block-list/block)
  Future<Map<String, dynamic>> blockUser({
    required String femaleUserId,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.maleBlockAction}');
    final headers = await _getHeaders();
    final body = jsonEncode({
      "femaleUserId": femaleUserId
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to block user: ${response.body}');
    }
  }

  // Unblock user (POST /male-user/block-list/unblock)
  Future<Map<String, dynamic>> unblockUser({
    required String femaleUserId,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.maleUnblockAction}');
    final headers = await _getHeaders();
    final body = jsonEncode({
      "femaleUserId": femaleUserId
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to unblock user: ${response.body}');
    }
  }

  // Fetch block list (GET /male-user/block-list)
  Future<Map<String, dynamic>> fetchBlockList() async {
    final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.maleBlockList}');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch block list: ${response.body}');
    }
  }

  // Send follow request to a female user
  Future<Map<String, dynamic>> sendFollowRequest({
    required String femaleUserId,
  }) async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrls}${ApiEndPoints.maleFollowSend}',
    );
    final headers = await _getHeaders();
    final body = jsonEncode({"femaleUserId": femaleUserId});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // Handle 404 for follow request endpoint not found
      print('Follow request endpoint not found (404)');
      return {
        'success': false,
        'message': 'Unable to send follow request - service unavailable',
        'data': null,
      };
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to send follow request');
    }
  }

  // Cancel follow request
  Future<Map<String, dynamic>> cancelFollowRequest({
    required String femaleUserId,
  }) async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrls}${ApiEndPoints.maleFollowCancel}',
    );
    final headers = await _getHeaders();
    final body = jsonEncode({"femaleUserId": femaleUserId});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to cancel follow request');
    }
  }

  // Unfollow a female user
  Future<Map<String, dynamic>> unfollowUser({
    required String femaleUserId,
  }) async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrls}${ApiEndPoints.maleUnfollow}',
    );
    final headers = await _getHeaders();
    final body = jsonEncode({"femaleUserId": femaleUserId});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to unfollow user');
    }
  }

  // Fetch female users with pagination
  Future<List<Map<String, dynamic>>> fetchFemaleUsers({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // First, try the original browse-females endpoint
      final url = Uri.parse(
        '${ApiEndPoints.baseUrls}${ApiEndPoints.fetchfemaleusers}?page=$page&limit=$limit',
      );
      final headers = await _getHeaders();
      print('URL: $url');
      print('Headers: $headers');
      print('Token: $_authToken');

      final response = await http.get(url, headers: headers);
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        if (data is List) {
          // For now, return all users from the API response
          // The backend should ideally return only female users
          // but if it doesn't, we'll filter them
          List<dynamic> allUsers = data;

          // Check if the first item is male - if so, the API isn't filtering properly
          if (allUsers.isNotEmpty) {
            final firstUser = allUsers[0];
            final firstGender = firstUser['gender']?.toString()?.toLowerCase();
            if (firstGender == 'male' || firstGender == 'm') {
              print(
                'WARNING: Browse API returned male users when expecting females. Filtering...',
              );
              // Filter to ensure we only return female users
              final femaleUsers = allUsers.where((user) {
                final gender = user['gender']?.toString()?.toLowerCase();
                return gender != null && (gender == 'female' || gender == 'f');
              }).toList();
              print(
                'Found ${femaleUsers.length} female users out of ${allUsers.length} total',
              );

              // If no female users are found after filtering, return the original data
              // This prevents empty results when the API doesn't properly filter on the backend
              if (femaleUsers.isEmpty) {
                print(
                  'WARNING: No female users found after filtering. Returning original data as fallback.',
                );
                return allUsers
                    .map<Map<String, dynamic>>(
                      (e) => Map<String, dynamic>.from(e),
                    )
                    .toList();
              }

              return femaleUsers
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList();
            }
          }

          // If the first user is female or unknown, return all
          return allUsers
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        } else if (data is Map && data['results'] is List) {
          // Handle case where data has a results property
          return (data['results'] as List)
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        } else {
          print('Unexpected browse API data format: $data');
          // Check if response has a different structure
          if (decoded is Map<String, dynamic>) {
            // Handle case where data is not in 'data' field
            if (decoded.containsKey('users') && decoded['users'] is List) {
              return (decoded['users'] as List)
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList();
            } else if (decoded.containsKey('results') &&
                decoded['results'] is List) {
              return (decoded['results'] as List)
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList();
            }
          }
          return <Map<String, dynamic>>[];
        }
      } else if (response.statusCode == 404) {
        // If browse-females doesn't exist, fall back to dashboard endpoint
        print(
          'Browse-females endpoint not found (404), falling back to dashboard',
        );
        return await _fetchFemaleUsersFromDashboard(page: page, limit: limit);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to load female users');
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception('Network error: $e');
    } on http.ClientException catch (e) {
      print('ClientException: $e');
      throw Exception('Connection error: $e');
    } catch (e, st) {
      print('General Exception in fetchFemaleUsers: $e\n$st');
      throw Exception('Network error: $e');
    }
  }

  // Fallback method for fetching female users from dashboard
  Future<List<Map<String, dynamic>>> _fetchFemaleUsersFromDashboard({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiEndPoints.baseUrls}${ApiEndPoints.dashboardEndpoint}?section=all&page=$page&limit=$limit',
      );
      final headers = await _getHeaders();
      print('Dashboard fallback URL: $url');
      print('Headers: $headers');
      print('Token: $_authToken');

      final response = await http.get(url, headers: headers);
      print('Dashboard API Response Status: ${response.statusCode}');
      print('Dashboard API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        if (data is List) {
          // For now, return all users from the API response
          // The backend should ideally return only female users
          // but if it doesn't, we'll filter them
          List<dynamic> allUsers = data;

          // Check if the first item is male - if so, the API isn't filtering properly
          if (allUsers.isNotEmpty) {
            final firstUser = allUsers[0];
            final firstGender = firstUser['gender']?.toString()?.toLowerCase();
            if (firstGender == 'male' || firstGender == 'm') {
              print(
                'WARNING: Dashboard API returned male users when expecting females. Filtering...',
              );
              // Filter to ensure we only return female users
              final femaleUsers = allUsers.where((user) {
                final gender = user['gender']?.toString()?.toLowerCase();
                return gender != null && (gender == 'female' || gender == 'f');
              }).toList();
              print(
                'Found ${femaleUsers.length} female users out of ${allUsers.length} total',
              );

              // If no female users are found after filtering, return the original data
              // This prevents empty results when the API doesn't properly filter on the backend
              if (femaleUsers.isEmpty) {
                print(
                  'WARNING: No female users found after filtering. Returning original data as fallback.',
                );
                return allUsers
                    .map<Map<String, dynamic>>(
                      (e) => Map<String, dynamic>.from(e),
                    )
                    .toList();
              }

              return femaleUsers
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList();
            }
          }

          // If the first user is female or unknown, return all
          return allUsers
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        } else if (data is Map && data['results'] is List) {
          // Handle case where data has a results property
          return (data['results'] as List)
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        } else {
          print('Unexpected dashboard data format: $data');
          // Check if response has a different structure
          if (decoded is Map<String, dynamic>) {
            // Handle case where data is not in 'data' field
            if (decoded.containsKey('users') && decoded['users'] is List) {
              return (decoded['users'] as List)
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList();
            } else if (decoded.containsKey('results') &&
                decoded['results'] is List) {
              return (decoded['results'] as List)
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList();
            }
          }
          return <Map<String, dynamic>>[];
        }
      } else if (response.statusCode == 404) {
        // Handle 404 for no female users found
        print('No female users found (404) - returning empty list');
        return <Map<String, dynamic>>[];
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to load female users from dashboard');
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception('Network error: $e');
    } on http.ClientException catch (e) {
      print('ClientException: $e');
      throw Exception('Connection error: $e');
    } catch (e, st) {
      print('General Exception in _fetchFemaleUsersFromDashboard: $e\n$st');
      throw Exception('Network error: $e');
    }
  }

  // Fallback method for fetching female users
  Future<List<Map<String, dynamic>>> _fetchFemaleUsersFallback({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiEndPoints.baseUrls}${ApiEndPoints.fetchfemaleusers}?page=$page&limit=$limit',
      );
      final headers = await _getHeaders();
      print('Fallback URL: $url');
      print('Headers: $headers');
      print('Token: $_authToken');

      final response = await http.get(url, headers: headers);
      print('Fallback API Response Status: ${response.statusCode}');
      print('Fallback API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final success = decoded['success'] ?? true;

        if (!success) {
          print('Fallback API returned failure: ${decoded["message"]}');
          return <Map<String, dynamic>>[];
        }

        final data = decoded['data'];
        if (data is List) {
          // For now, return all users from the API response
          // The backend should ideally return only female users
          // but if it doesn't, we'll filter them
          List<dynamic> allUsers = data;

          // Check if the first item is male - if so, the API isn't filtering properly
          if (allUsers.isNotEmpty) {
            final firstUser = allUsers[0];
            final firstGender = firstUser['gender']?.toString()?.toLowerCase();
            if (firstGender == 'male' || firstGender == 'm') {
              print(
                'WARNING: Fallback API returned male users when expecting females. Filtering...',
              );
              // Filter to ensure we only return female users
              final femaleUsers = allUsers.where((user) {
                final gender = user['gender']?.toString()?.toLowerCase();
                return gender != null && (gender == 'female' || gender == 'f');
              }).toList();
              print(
                'Found ${femaleUsers.length} female users out of ${allUsers.length} total',
              );

              // If no female users are found after filtering, return the original data
              // This prevents empty results when the API doesn't properly filter on the backend
              if (femaleUsers.isEmpty) {
                print(
                  'WARNING: No female users found after filtering. Returning original data as fallback.',
                );
                return allUsers
                    .map<Map<String, dynamic>>(
                      (e) => Map<String, dynamic>.from(e),
                    )
                    .toList();
              }

              return femaleUsers
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList();
            }
          }

          // If the first user is female or unknown, return all
          return allUsers
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        } else {
          print('Unexpected fallback data format: $data');
          // Check if response has a different structure
          if (decoded is Map<String, dynamic>) {
            // Handle case where data is not in 'data' field
            if (decoded.containsKey('users') && decoded['users'] is List) {
              return (decoded['users'] as List)
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList();
            } else if (decoded.containsKey('results') &&
                decoded['results'] is List) {
              return (decoded['results'] as List)
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList();
            }
          }
          return <Map<String, dynamic>>[];
        }
      } else if (response.statusCode == 404) {
        // Handle 404 for no female users found
        print('No female users found (404) - returning empty list');
        return <Map<String, dynamic>>[];
      } else {
        print('Fallback Error: ${response.statusCode} - ${response.body}');
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to load female users from fallback endpoint');
      }
    } on SocketException catch (e) {
      print('SocketException in fallback: $e');
      throw Exception('Network error: $e');
    } on http.ClientException catch (e) {
      print('ClientException in fallback: $e');
      throw Exception('Connection error: $e');
    } catch (e, st) {
      print('General Exception in _fetchFemaleUsersFallback: $e\n$st');
      throw Exception('Network error: $e');
    }
  }

  // Method for browsing female users
  Future<List<Map<String, dynamic>>> fetchBrowseFemales({
    int page = 1,
    int limit = 10,
  }) async {
    // Since the browse-females endpoint doesn't exist, use dashboard endpoint instead
    // This maintains compatibility while using the working endpoint
    try {
      final url = Uri.parse(
        '${ApiEndPoints.baseUrls}${ApiEndPoints.dashboardEndpoint}?section=all&page=$page&limit=$limit',
      );
      final headers = await _getHeaders();
      print('Dashboard URL: $url');
      print('Headers: $headers');
      print('Token: $_authToken');

      final response = await http.get(url, headers: headers);
      print('Dashboard API Response Status: ${response.statusCode}');
      print('Dashboard API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        if (data is List) {
          print('Browse endpoint returned ${data.length} profiles as List');
          return data
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        } else if (data is Map && data['results'] is List) {
          // Handle case where data has a results property
          final results = (data['results'] as List)
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
          print(
            'Browse endpoint returned ${results.length} profiles as Map.results',
          );
          return results;
        } else {
          print(
            'Browse endpoint returned unexpected data format: ${data.runtimeType}',
          );
          return <Map<String, dynamic>>[];
        }
      } else if (response.statusCode == 404) {
        // Handle 404 for no female users found in browse
        print('No female users found in browse (404) - returning empty list');
        return <Map<String, dynamic>>[];
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to load female users');
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception('Network error: $e');
    } on http.ClientException catch (e) {
      print('ClientException: $e');
      throw Exception('Connection error: $e');
    } catch (e, st) {
      print('General Exception in fetchBrowseFemales: $e\n$st');
      throw Exception('Network error: $e');
    }
  }

  // Register new male user
  Future<Map<String, dynamic>> registerMaleUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiEndPoints.baseUrls}${ApiEndPoints.signupMale}',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          if (referralCode != null) 'referralCode': referralCode,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to register user: ${response.body}');
      }
    } on SocketException catch (e) {
      print('[ERROR] SocketException in registration: $e');
      throw Exception('Network error: Please check your internet connection.');
    } on http.ClientException catch (e) {
      print('[ERROR] ClientException in registration: $e');
      throw Exception(
        'Connection error: Please check your internet connection.',
      );
    } on TimeoutException catch (e) {
      print('[ERROR] TimeoutException in registration: Request timed out');
      throw Exception('Request timeout: Server is taking too long to respond.');
    } catch (e) {
      print('[ERROR] Unexpected error in registration: $e');
      throw Exception('Registration error: $e');
    }
  }

  // Fetch female users from dashboard with section, page and limit parameters
  Future<Map<String, dynamic>> fetchFemaleUsersFromDashboard({
    String section = 'all',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Use GET with query parameters instead of POST with body
      final url = Uri.parse('$baseUrl${ApiEndPoints.dashboardEndpoint}')
          .replace(
            queryParameters: {
              'section': section,
              'page': page.toString(),
              'limit': limit.toString(),
            },
          );
      final headers = await _getHeaders();
      print('Dashboard URL: $url');
      print('Headers: $headers');
      print('Token: $_authToken');

      final response = await http.get(url, headers: headers);
      print('Dashboard API Response Status: ${response.statusCode}');
      print('Dashboard API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // Validate the response structure matches expected format
        if (decoded is Map) {
          final typedDecoded = Map<String, dynamic>.from(decoded);
          if (typedDecoded.containsKey('success')) {
            return typedDecoded;
          } else {
            print(
              'Warning: Unexpected response format from dashboard API: $typedDecoded',
            );
            return typedDecoded;
          }
        } else {
          print(
            'Error: Expected Map response from dashboard API, got ${decoded.runtimeType}',
          );
          throw Exception('Invalid response format from dashboard API');
        }
      } else {
        print('Dashboard Error: ${response.statusCode} - ${response.body}');
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to load female users from dashboard');
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception('Network error: $e');
    } on http.ClientException catch (e) {
      print('ClientException: $e');
      throw Exception('Connection error: $e');
    } catch (e, st) {
      print('General Exception in fetchFemaleUsersFromDashboard: $e\n$st');
      throw Exception('Network error: $e');
    }
  }

  // Fetch user profile
  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndPoints.baseUrls}/api/user/profile'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        // Handle 404 for user profile not found
        print('User profile not found (404)');
        return {
          'success': false,
          'message': 'User profile not found',
          'data': null,
        };
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Fetch followed female users
  Future<List<Map<String, dynamic>>> fetchFollowedFemales({
    int page = 1,
    int limit = 10,
  }) async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrls}${ApiEndPoints.dashboardEndpoint}',
    );
    final headers = await _getHeaders();
    final body = json.encode({
      'section': 'follow',
      'page': page,
      'limit': limit,
    });
    final response = await http
        .post(url, headers: headers, body: body)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Request to followed users API timed out');
          },
        );
    print('URL: $url');
    print('Headers: $headers');
    print('Token: $_authToken');
    print('Body: $body');
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final data = decoded['data'];
      if (data is List) {
        return data
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        return <Map<String, dynamic>>[];
      }
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch followed users');
    }
  }

  // Update profile and image
  Future<Map<String, dynamic>> updateProfileAndImage({
    required Map<String, String> fields,
    File? imageFile,
  }) async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrls}${ApiEndPoints.maleProfileAndImage}',
    );
    final headers = await _getHeaders();
    final request = http.MultipartRequest('POST', url);
    
    // Add headers
    request.headers.addAll(headers);

    // Add fields
    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add image if provided
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    print('Request Fields: ${request.fields}');
    if (request.files.isNotEmpty) {
      for (var f in request.files) {
        print('Request File: field=${f.field}, filename=${f.filename}');
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to update profile and image');
    }
  }


  // Fetch male user profile and images
  Future<Map<String, dynamic>> fetchMaleProfileAndImage() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.maleProfileAndImage}'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return {'success': true, 'data': decoded};
      } else if (response.statusCode == 404) {
        // Handle 404 for profile and images not found
        print('Male profile and images not found (404)');
        return {
          'success': false,
          'message': 'Profile and images not found',
          'data': null,
        };
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception(
          'Failed to fetch male profile and images: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }


  // Fetch call history
  Future<Map<String, dynamic>> fetchCallHistory({
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiEndPoints.baseUrls}${ApiEndPoints.callHistory}?limit=$limit&skip=$skip',
      );
      final headers = await _getHeaders();

      print('Fetching call history from: $url');
      print('Headers: $headers');

      final response = await http.get(url, headers: headers);

      print('Call history response status: ${response.statusCode}');
      print('Call history response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to fetch call history');
      }
    } catch (e) {
      print('Error fetching call history: $e');
      throw Exception('Failed to fetch call history: $e');
    }
  }

  // Fetch call statistics
  Future<Map<String, dynamic>> fetchCallStats() async {
    try {
      final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.callStats}');
      final headers = await _getHeaders();

      print('Fetching call stats from: $url');
      print('Headers: $headers');

      final response = await http.get(url, headers: headers);

      print('Call stats response status: ${response.statusCode}');
      print('Call stats response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to fetch call stats');
      }
    } catch (e) {
      print('Error fetching call stats: $e');
      throw Exception('Failed to fetch call stats: $e');
    }
  }

  // Fetch all gifts
  Future<List<Gift>> getAllGifts() async {
    try {
      final headers = await _getHeaders();
      print('Fetching gifts from: ${ApiEndPoints.baseUrls}/male-user/gifts');

      final response = await _dio.get(
        '/male-user/gifts',
        options: Options(headers: headers),
      );

      print('Gifts response status: ${response.statusCode}');
      print('Gifts response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] is List) {
          return List<Gift>.from(
            data['data'].map((item) => Gift.fromJson(item)),
          );
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
          'Failed to fetch gifts. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('DioException in gifts: $e');
      if (e.response != null) {
        switch (e.response?.statusCode) {
          case 401:
            throw Exception('Unauthorized: Please log in again');
          case 403:
            throw Exception(
              'Forbidden: You do not have permission to access gifts',
            );
          case 500:
            throw Exception('Internal Server Error: Please try again later');
          default:
            throw Exception(
              'Error: ${e.response?.statusMessage ?? 'Unknown error'}',
            );
        }
      } else {
        throw Exception('Network error: Please check your connection');
      }
    } catch (e) {
      print('Unexpected error in gifts: $e');
      throw Exception('Failed to fetch gifts: $e');
    }
  }

  // Send gift to female user
  Future<SendGiftResponse> sendGift(String femaleUserId, String giftId) async {
    try {
      final headers = await _getHeaders();
      print('Sending gift to female user: $femaleUserId, giftId: $giftId');

      final response = await _dio.post(
        '/male-user/gifts/send',
        data: {'femaleUserId': femaleUserId, 'giftId': giftId},
        options: Options(headers: headers),
      );

      print('Send gift response status: ${response.statusCode}');
      print('Send gift response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return SendGiftResponse.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'Failed to send gift');
        }
      } else {
        throw Exception('Failed to send gift. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException in send gift: $e');
      if (e.response != null) {
        switch (e.response?.statusCode) {
          case 400:
            throw Exception(
              'Invalid request: ${e.response?.data?['message'] ?? 'Validation error'}',
            );
          case 401:
            throw Exception('Unauthorized: Please log in again');
          case 403:
            throw Exception(
              'Forbidden: You do not have permission to send gifts',
            );
          case 500:
            throw Exception('Internal Server Error: Please try again later');
          default:
            throw Exception(
              'Error: ${e.response?.statusMessage ?? 'Unknown error'}',
            );
        }
      } else {
        throw Exception('Network error: Please check your connection');
      }
    } catch (e) {
      print('Unexpected error in send gift: $e');
      throw Exception('Failed to send gift: $e');
    }
  }

  // Get profile details for the logged-in user
  Future<ProfileModel> getProfileDetails() async {
    try {
      final headers = await _getHeaders();
      print(
        'Fetching profile details from: ${ApiEndPoints.baseUrls}/male-user/profile-and-image',
      );

      // For multipart form data, we'll send an empty form data as the API expects it
      final formData = FormData.fromMap({});

      final response = await _dio.post(
        '/male-user/profile-and-image',
        data: formData,
        options: Options(headers: headers),
      );

      print('Profile details response status: ${response.statusCode}');
      print('Profile details response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return ProfileModel.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch profile details');
        }
      } else {
        throw Exception(
          'Failed to fetch profile details. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('DioException in profile details: $e');
      if (e.response != null) {
        switch (e.response?.statusCode) {
          case 401:
            throw Exception('Unauthorized: Please log in again');
          case 500:
            throw Exception('Internal Server Error: Please try again later');
          default:
            throw Exception(
              'Error: ${e.response?.statusMessage ?? 'Unknown error'}',
            );
        }
      } else {
        throw Exception('Network error: Please check your connection');
      }
    } catch (e) {
      print('Unexpected error in profile details: $e');
      throw Exception('Failed to fetch profile details: $e');
    }
  }

  // Delete accountPermanently
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.deleteAccountMale}');
      final headers = await _getHeaders();
      
      final response = await http.delete(url, headers: headers);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Fetch chat rooms
  Future<Map<String, dynamic>> fetchChatRooms() async {
    try {
      final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.chatRooms}');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to fetch chat rooms');
      }
    } catch (e) {
      throw Exception('Failed to fetch chat rooms: $e');
    }
  }

  // Fetch wallet transactions
  Future<Map<String, dynamic>> fetchWalletTransactions() async {
    try {
      final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.walletTransactions}');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to fetch wallet transactions');
      }
    } catch (e) {
      throw Exception('Failed to fetch wallet transactions: $e');
    }
  }

  // Start chat with female user
  Future<Map<String, dynamic>> startChat(String femaleId) async {
    try {
      final url = Uri.parse('${ApiEndPoints.baseUrls}${ApiEndPoints.chatStart}');
      final headers = await _getHeaders();
      final body = json.encode({'femaleId': femaleId});
      
      final response = await http.post(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to start chat');
      }
    } catch (e) {
      throw Exception('Failed to start chat: $e');
    }
  }


  // Fetch wallet transactions by date range
  Future<List<WalletTransaction>> getWalletTransactionsByDate(
    String startDate,
    String endDate,
  ) async {
    try {
      final url = Uri.parse(
        '${ApiEndPoints.baseUrls}/male-user/me/transactions?operationType=wallet&startDate=$startDate&endDate=$endDate',
      );
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<WalletTransaction>.from(
            data['data'].map((item) => WalletTransaction.fromJson(item)),
          );
        }
        return [];
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to fetch wallet transactions by date');
      }
    } catch (e) {
      print('Error fetching wallet transactions by date: $e');
      throw Exception('Failed to fetch wallet transactions by date: $e');
    }
  }
}
