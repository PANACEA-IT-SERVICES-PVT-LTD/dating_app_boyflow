import 'dart:convert';
import 'package:boy_flow/api_service/api_endpoint.dart';
import 'package:http/http.dart' as http;

class RazorpayService {
  // 🔐 Put your MALE USER JWT here for testing
  static const String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5NWI1MTJlM2RkMGIwNTA5MmRlMDc3NiIsInR5cGUiOiJtYWxlIiwiaWF0IjoxNzcwMjc0NzMyLCJleHAiOjE3NzAzNjExMzJ9.zLjRFIbAn9WqCJKV7i25I51SCQE9KAedzSRIckNnfcQ";

  // Create coin order
  static Future<Map<String, dynamic>> createCoinOrder(String packageId) async {
    final url = Uri.parse("${ApiEndPoints.baseUrls}${ApiEndPoints.coinOrder}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({"packageId": packageId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["success"] != true) {
      throw Exception(data["message"] ?? "Order creation failed");
    }

    return data["data"];
  }

  // Verify payment
  static Future<bool> verifyPayment(Map<String, dynamic> payload) async {
    final url = Uri.parse("${ApiEndPoints.baseUrls}${ApiEndPoints.paymentVerify}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(payload),
    );

    final data = jsonDecode(response.body);
    return data["success"] == true;
  }

  // Fetch coin packages
  static Future<List<dynamic>> fetchPackages() async {
    final url = Uri.parse("${ApiEndPoints.baseUrls}${ApiEndPoints.paymentPackages}");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data["success"] != true) {
      throw Exception(data["message"] ?? "Failed to fetch packages");
    }

    return data["data"] ?? [];
  }
}
