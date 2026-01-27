import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/female_user.dart';
import '../api_service/api_endpoint.dart';

class ApiService {
  // Fetch male user's wallet transactions
  Future<Map<String, dynamic>> fetchMaleWalletTransactions() async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrl}/male-user/me/transactions?operationType=wallet',
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

  // Fetch male user's coin transactions
  Future<Map<String, dynamic>> fetchMaleCoinTransactions() async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrl}/male-user/me/transactions?operationType=coin',
    );
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch transactions');
    }
  }

  /// End an active call (audio or video)
  Future<Map<String, dynamic>> endCall({
    required String receiverId,
    required int duration,
    required String callType, // "audio" or "video"
    required String callId,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrl}${ApiEndPoints.endCall}');
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
  final String baseUrl = ApiEndPoints.baseUrl;

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

  // Start a call (audio or video)
  Future<Map<String, dynamic>> startCall({
    required String receiverId,
    required String callType, // "audio" or "video"
  }) async {
    final callUrl = ApiEndPoints.baseUrl + ApiEndPoints.startCall;
    print('CALL API URL => $callUrl');

    final headers = await _getHeaders();
    final body = json.encode({'receiverId': receiverId, 'callType': callType});

    final response = await http.post(
      Uri.parse(callUrl),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to start call: ${response.body}');
    }
  }

  // Check call status
  Future<Map<String, dynamic>> checkCallStatus({required String callId}) async {
    final statusUrl =
        ApiEndPoints.baseUrl + ApiEndPoints.checkCallStatus + '/$callId/status';
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
        final jsonResponse = json.decode(responseBody);
        message = jsonResponse['message'] ?? message;
        if (message.toLowerCase().contains('user not found')) {
          throw Exception(
            'Your session has expired or user does not exist. Please log in again.',
          );
        }
      }
    } catch (e) {
      message = 'Error: $statusCode';
    }
    if (statusCode == 404) {
      if (responseBody.toString().toLowerCase().contains('user') ||
          responseBody.toString().toLowerCase().contains('profile')) {
        message = 'User profile not found (404). Please log in again.';
      } else {
        message = 'Resource does not exist (404).';
      }
    }
    throw Exception(message);
  }

  // Fetch all female users for dashboard section
  Future<Map<String, dynamic>> fetchDashboardSectionFemales({
    String section = 'all',
    int page = 1,
    int limit = 10,
    double? latitude,
    double? longitude,
  }) async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrl}${ApiEndPoints.dashboardEndpoint}',
    );
    final headers = await _getHeaders();
    final bodyMap = {'section': section, 'page': page, 'limit': limit};
    if (latitude != null && longitude != null) {
      bodyMap['location'] = {'latitude': latitude, 'longitude': longitude};
    }
    final body = json.encode(bodyMap);
    final response = await http
        .post(url, headers: headers, body: body)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Request to dashboard API timed out');
          },
        );
    print('URL: $url');
    print('Headers: $headers');
    print('Token: $_authToken');
    print('Body: $body');
    if (response.statusCode == 200) {
      print('API raw response body: ${response.body}');
      final result = json.decode(response.body);
      // Return the full response, the controller will handle parsing
      return result;
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch dashboard $section female users');
    }
  }

  // Fetch all female users for dashboard 'all' section
  Future<Map<String, dynamic>> fetchDashboardAllFemales({
    int page = 1,
    int limit = 10,
  }) async {
    return await fetchDashboardSectionFemales(
      section: 'all',
      page: page,
      limit: limit,
    );
  }

  // Fetch all dropdown options from profile-and-image endpoint
  Future<Map<String, dynamic>> fetchProfileAndImageOptions() async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrl}${ApiEndPoints.maleProfileAndImage}',
    );
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch profile and image options');
    }
  }

  // Fetch male user profile (GET /male-user/me)
  Future<Map<String, dynamic>> fetchMaleMe() async {
    final url = Uri.parse('${ApiEndPoints.baseUrl}/male-user/me');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch male user profile');
    }
  }

  // Fetch all available sports
  Future<List<String>> fetchAllSports() async {
    final url = Uri.parse('${ApiEndPoints.baseUrl}${ApiEndPoints.maleSports}');
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
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch sports');
    }
  }

  // Fetch all available film
  Future<List<String>> fetchAllFilm() async {
    final url = Uri.parse('${ApiEndPoints.baseUrl}${ApiEndPoints.maleFilm}');
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
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch film');
    }
  }

  // Fetch all available music
  Future<List<String>> fetchAllMusic() async {
    final url = Uri.parse('${ApiEndPoints.baseUrl}${ApiEndPoints.maleMusic}');
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
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch music');
    }
  }

  // Fetch all available travel
  Future<List<String>> fetchAllTravel() async {
    final url = Uri.parse('${ApiEndPoints.baseUrl}${ApiEndPoints.maleTravel}');
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
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch travel');
    }
  }

  // Upload image for male user
  Future<Map<String, dynamic>> uploadUserImage({
    required File imageFile,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrl}/male-user/upload-image');
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
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to upload image');
    }
  }

  // Update travel preferences for male user
  Future<Map<String, dynamic>> updateUserTravel({
    required List<String> travel,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrl}/male-user/travel');
    final headers = await _getHeaders();
    final request = http.MultipartRequest('PATCH', url);
    request.headers.addAll(headers);
    request.fields['travel'] = jsonEncode(travel);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to update travel preferences');
    }
  }

  // Update music preferences for male user
  Future<Map<String, dynamic>> updateUserMusic({
    required List<String> music,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrl}/male-user/music');
    final headers = await _getHeaders();
    final request = http.MultipartRequest('PATCH', url);
    request.headers.addAll(headers);
    request.fields['music'] = jsonEncode(music);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to update music preferences');
    }
  }

  // Update film preferences for male user
  Future<Map<String, dynamic>> updateUserFilm({
    required List<String> film,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrl}/male-user/film');
    final headers = await _getHeaders();
    final request = http.MultipartRequest('PATCH', url);
    request.headers.addAll(headers);
    request.fields['film'] = jsonEncode(film);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to update film preferences');
    }
  }

  // Update sports for male user
  Future<Map<String, dynamic>> updateUserSports({
    required List<String> sports,
  }) async {
    final url = Uri.parse('${ApiEndPoints.baseUrl}/male-user/sports');
    final headers = await _getHeaders();
    final request = http.MultipartRequest('PATCH', url);
    request.headers.addAll(headers);
    request.fields['sports'] = jsonEncode(sports);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to update sports');
    }
  }

  // Login method (stub, implement as needed)
  Future<bool> login(String email) async {
    // TODO: Implement actual login logic (send OTP, etc.)
    // For now, just return true to allow flow
    return true;
  }

  // Update user profile (stub, implement as needed)
  Future<Map<String, dynamic>> updateUserProfile({
    required Map<String, dynamic> fields,
    List<http.MultipartFile>? images,
  }) async {
    // TODO: Implement actual update logic
    return {'success': true, 'message': 'Profile updated (stub)'};
  }

  // Update profile details (stub, implement as needed)
  Future<Map<String, dynamic>> updateProfileDetails({
    String? firstName,
    String? lastName,
    String? height,
    String? religion,
    String? imageUrl,
  }) async {
    // TODO: Implement actual update logic
    return {'success': true, 'message': 'Profile details updated (stub)'};
  }

  // Fetch current male profile (stub, implement as needed)
  Future<Map<String, dynamic>> fetchCurrentMaleProfile() async {
    // TODO: Implement actual fetch logic
    return {'success': true, 'data': {}};
  }

  // Fetch sent follow requests
  Future<List<Map<String, dynamic>>> fetchSentFollowRequests() async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrl}/male-user/follow-requests/sent',
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
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch sent follow requests');
    }
  }

  // Send follow request to a female user
  Future<Map<String, dynamic>> sendFollowRequest({
    required String femaleUserId,
  }) async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrl}/male-user/follow-request/send',
    );
    final headers = await _getHeaders();
    final body = jsonEncode({"femaleUserId": femaleUserId});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to send follow request');
    }
  }

  // Fetch female users with pagination
  Future<List<Map<String, dynamic>>> fetchFemaleUsers({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.fetchfemaleusers}?page=$page&limit=$limit',
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
                'WARNING: API returned male users when expecting females. Filtering...',
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
          print('Unexpected data format: $data');
          return <Map<String, dynamic>>[];
        }
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
        '${ApiEndPoints.baseUrl}${ApiEndPoints.signupMale}',
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
        throw Exception('Failed to register user');
      }
    } on SocketException {
      throw Exception('Network error: Please check your internet connection');
    } on http.ClientException {
      throw Exception('Connection error: Unable to connect to server');
    } catch (e) {
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
      final url = Uri.parse(
        '$baseUrl${ApiEndPoints.dashboardEndpoint}?section=$section&page=$page&limit=$limit',
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
        Uri.parse('${ApiEndPoints.baseUrl}/api/user/profile'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  // Fetch followed female users
  Future<Map<String, dynamic>> fetchFollowedFemales({
    int page = 1,
    int limit = 10,
  }) async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrl}${ApiEndPoints.dashboardEndpoint}',
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
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch followed female users');
    }
  }

  // Fetch male user profile and images
  Future<Map<String, dynamic>> fetchMaleProfileAndImage() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndPoints.baseUrl}${ApiEndPoints.maleProfileAndImage}'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to fetch male profile and images');
      }
    } catch (e) {
      throw Exception('Failed to fetch profile and images: $e');
    }
  }

  // Block a female user
  Future<Map<String, dynamic>> blockUser({required String femaleUserId}) async {
    try {
      final url = Uri.parse('${ApiEndPoints.baseUrl}${ApiEndPoints.maleBlock}');
      final headers = await _getHeaders();
      final body = jsonEncode({"femaleUserId": femaleUserId});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to block user');
      }
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  // Fetch blocked users list
  Future<Map<String, dynamic>> fetchBlockedUsersList({
    required String femaleUserId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndPoints.baseUrl}${ApiEndPoints.maleBlockList}'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to fetch blocked users list');
      }
    } catch (e) {
      throw Exception('Failed to fetch blocked users list: $e');
    }
  }

  // Unblock a female user
  Future<Map<String, dynamic>> unblockUser({
    required String femaleUserId,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.maleUnblock}',
      );
      final headers = await _getHeaders();
      final body = jsonEncode({"femaleUserId": femaleUserId});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to unblock user');
      }
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  // Fetch call history
  Future<Map<String, dynamic>> fetchCallHistory({
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiEndPoints.baseUrl}${ApiEndPoints.callHistory}?limit=$limit&skip=$skip',
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
      final url = Uri.parse('${ApiEndPoints.baseUrl}${ApiEndPoints.callStats}');
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
}
