import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:3000/user";

  // Sign Up
  static Future<Map<String, dynamic>> signUp(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  // Sign In
  static Future<Map<String, dynamic>> signIn(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }

  //OTP
  static Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    final response = await http.post(
      Uri.parse("$baseUrl/verify"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "code": code,
      }),
    );
    return jsonDecode(response.body);
  }

  // api_service.dart
  static Future<Map<String, dynamic>> analyzeBodyImage(String base64Image) async {
    final response = await http.post(
      Uri.parse("http://localhost:3000/ai/analyze"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"imageBase64": base64Image}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Body measurement analysis failed");
    }
  }

}
