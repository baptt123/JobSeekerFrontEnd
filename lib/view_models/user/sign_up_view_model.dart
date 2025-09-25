import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:job_seeker_frontend/dto/register_dto.dart';
import '../../models/user-entity.dart';


class SignupViewModel extends ChangeNotifier {
  String fullName = "";
  String email = "";
  String password = "";
  bool rememberMe = false;
  bool isPasswordVisible = false;

  void setFullName(String value) {
    fullName = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void setRememberMe(bool? value) {
    rememberMe = value ?? false;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  Future<UserEntity?> signUp(BuildContext context) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/auth/register');
    final dto = RegisterDto(
      fullName: fullName,
      email: email,
      password: password,
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dto.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserEntity.fromJson(data['user']);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign up thành công!")),
        );

        return user;
      } else {
        final err = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err['message'] ?? 'Đăng ký thất bại')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối: $e")),
      );
      return null;
    }
  }
}
