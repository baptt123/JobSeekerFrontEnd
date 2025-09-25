import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/token_storage.dart';

class AuthService {
  static const baseUrl = 'http://localhost:3000/auth';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await TokenStorage.saveTokens(data['accessToken'], data['refreshToken']);
      return data;
    } else {
      throw Exception(jsonDecode(res.body)['message'] ?? 'Login failed');
    }
  }


}
