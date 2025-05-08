import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
    String role,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password, 'role': role}),
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': responseBody['message'] ?? 'Login successful',
      };
    } else {
      return {
        'success': false,
        'message': responseBody['message'] ?? 'Login failed',
      };
    }
  }
}
