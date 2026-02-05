import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing Dashboard API...\n');

  // You'll need to replace this with a valid token from your app
  final token = 'YOUR_TOKEN_HERE';
  
  final baseUrl = 'https://friend-circle-2.vercel.app';
  final sections = ['all', 'new', 'follow', 'nearby'];

  for (final section in sections) {
    print('Testing section: $section');
    print('=' * 50);
    
    final url = Uri.parse('$baseUrl/male-user/dashboard?section=$section&page=1&limit=10');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print('Decoded Response:');
        print(json.encode(decoded));
        
        // Check structure
        if (decoded is Map) {
          print('\nResponse Keys: ${decoded.keys.toList()}');
          
          if (decoded.containsKey('data')) {
            print('Data type: ${decoded['data'].runtimeType}');
            if (decoded['data'] is Map && decoded['data'].containsKey('results')) {
              final results = decoded['data']['results'];
              print('Results count: ${results is List ? results.length : 'N/A'}');
            }
          }
        }
      }
      
      print('\n');
    } catch (e) {
      print('Error: $e\n');
    }
  }
}
