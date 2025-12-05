import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/female_user.dart';
import '../api_service/api_endpoint.dart';

class ApiService {
  final String baseUrl = ApiEndPoints.baseUrls;
  String? _authToken;

  // Get auth token from shared preferences
  Future<void> _getAuthToken() async {
    if (_authToken == null) {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
    }
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
      }
    } catch (e) {
      // If we can't parse the error message, use the status code
      message = 'Error: $statusCode';
    }
    throw Exception(message);
  }

  // Fetch female users with pagination
  Future<FemaleUserResponse> fetchFemaleUsers({ int page = 1,int limit = 10, }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/app/male-user/browse-females?page=$page&limit=$limit'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return FemaleUserResponse.fromJson(json.decode(response.body));
      } else {
        _handleError(response.statusCode, response.body);
        throw Exception('Failed to load female users');
      }
    } catch (e) {
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
}
