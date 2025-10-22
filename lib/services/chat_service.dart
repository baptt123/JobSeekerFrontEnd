import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl = 'http://192.168.67.109:3000';

  Future<Map<String, dynamic>> loginByFullName(String fullName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/login'),
      body: jsonEncode({'full_name': fullName}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Không tìm thấy người dùng');
    }
  }
}
