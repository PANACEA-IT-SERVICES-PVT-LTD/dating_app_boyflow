import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/female_user.dart';
import '../api_service/api_endpoint.dart';

class ApiService {
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
      '${ApiEndPoints.baseUrls}/male-user/follow-requests/sent',
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
      '${ApiEndPoints.baseUrls}/male-user/follow-request/send',
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

  final String baseUrl = ApiEndPoints.baseUrls;
  String? _authToken;

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
      message = 'No profiles found or resource does not exist (404).';
    }
    throw Exception(message);
  }

  // Fetch female users with pagination
  Future<List<Map<String, dynamic>>> fetchFemaleUsers({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl${ApiEndPoints.fetchfemaleusers}?page=$page&limit=$limit',
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
          return data
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
      final url = Uri.parse('$baseUrl${ApiEndPoints.signupMale}');
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
        Uri.parse('$baseUrl/api/user/profile'),
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

  // Fetch followed female users for dashboard
  Future<Map<String, dynamic>> fetchFollowedFemales({
    int page = 1,
    int limit = 10,
  }) async {
    final url = Uri.parse(
      '$baseUrl/male-user/dashboard?section=followed&page=$page&limit=$limit',
    );
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    print('URL: $url');
    print('Headers: $headers');
    print('Token: $_authToken');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      _handleError(response.statusCode, response.body);
      throw Exception('Failed to fetch followed female users');
    }
  }
}
