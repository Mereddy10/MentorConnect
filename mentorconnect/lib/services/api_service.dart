import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000';
  // use your IP if testing on real device

  static Future<void> login(String email, String password) async {
    var url = Uri.parse('$baseUrl/auth/login');

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        print('✅ Login Success: ${response.body}');
      } else {
        print('❌ Login Failed: ${response.body}');
      }
    } catch (e) {
      print('⚠️ Error connecting to backend: $e');
    }
  }
}
