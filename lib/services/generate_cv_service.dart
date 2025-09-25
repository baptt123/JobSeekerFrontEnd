import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:convert';
import 'dart:typed_data' hide Uint8List;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../dto/create_user_cv_dto.dart';
import '../models/user-cv-entity.dart';

class GenerativeCVService {
  Future<Uint8List> generateCV(String prompt) async {
    // Simulate a network call to generate a CV based on the prompt
    await Future.delayed(Duration(seconds: 2));
    // Return a dummy PDF byte array
    final res = await http.post(
      Uri.parse(''),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    );
    return Uint8List.fromList(res.bodyBytes);
  }
  Future<UserCvEntity> createCvWithKeywords(CreateUserCvDto dto) async {
    final url = Uri.parse('');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      return UserCvEntity.fromJson(json);
    } else {
      throw Exception('Create CV failed: ${resp.statusCode} ${resp.body}');
    }
  }

}
