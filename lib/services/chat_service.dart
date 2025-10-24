import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_seeker_frontend/models/message-entity.dart';
import 'package:job_seeker_frontend/models/user-entity.dart';

import '../utils/constant_api.dart';

class ChatService {
  final String baseUrl =  ConstantAPI.baseUrl;

  Future<UserEntity> login(String fullName) async {
    final res = await http.post(
      Uri.parse('$baseUrl/messages/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'full_name': fullName}),
    );

    print('>>> Response status: ${res.statusCode}');
    print('>>> Response body: ${res.body}');

    if (res.statusCode == 200|| res.statusCode==201) {
      return UserEntity.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("User không tồn tại: ${res.body}");
    }
  }


  Future<List<MessageEntity>> getConversation(int userA, int userB) async {
    final res = await http.get(Uri.parse(
        '$baseUrl/messages/conversation?userA=$userA&userB=$userB'));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['messages'] as List)
          .map((e) => MessageEntity.fromJson(e))
          .toList();
    } else {
      throw Exception("Không thể tải cuộc trò chuyện");
    }
  }
}
