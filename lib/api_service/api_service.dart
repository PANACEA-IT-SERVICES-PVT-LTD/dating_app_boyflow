// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'api_endpoint.dart';

class ApiService {
  final String _baseUrl = ApiEndPoints.baseUrls;
  final Duration _timeout = const Duration(seconds: 20);

//   /// Generic JSON POST. Always returns a Map with `_status`.
//   Future<Map<String, dynamic>> postData(
//     String endpoint,
//     Map<String, dynamic> data,
//   ) async {
//     final url = Uri.parse("$_baseUrl$endpoint");

//     try {
//       debugPrint("📤 POST to $url with body: ${jsonEncode(data)}");

//       final response = await http
//           .post(
//             url,
//             headers: {"Content-Type": "application/json"},
//             body: jsonEncode(data),
//           )
//           .timeout(_timeout);

//       debugPrint("📥 Response ${response.statusCode}: ${response.body}");

//       dynamic parsedBody;
//       try {
//         parsedBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
//       } catch (_) {
//         parsedBody = {"raw": response.body};
//       }

      final Map<String, dynamic> result = <String, dynamic>{
        "_status": response.statusCode,
      };

      if (parsedBody is Map<String, dynamic>) {
        result.addAll(parsedBody);
      } else {
        result["data"] = parsedBody;
      }

//       return result;
//     } catch (e) {
//       throw Exception("POST request error: $e");
//     }
//   }
// }
