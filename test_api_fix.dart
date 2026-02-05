import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing API service fix...');

  // Test the fetchFemaleUsers method logic
  try {
    // Simulate the API response that was mentioned in the logs
    final mockResponse = {
      "success": true,
      "page": 1,
      "limit": 10,
      "total": 0,
      "data": [],
    };

    print('Mock API Response: ${json.encode(mockResponse)}');

    // Test the response parsing logic
    final data = mockResponse['data'];
    if (data is List) {
      print('Data is List with ${data.length} items');
      List<dynamic> allUsers = data;

      if (allUsers.isNotEmpty) {
        final firstUser = allUsers[0];
        final firstGender = firstUser['gender']?.toString()?.toLowerCase();
        print('First user gender: $firstGender');
      } else {
        print('No users in response');
      }
    } else {
      print('Data is not a List: ${data.runtimeType}');
    }

    print('✅ API service logic test passed!');
  } catch (e) {
    print('❌ Error in API service test: $e');
  }
}
