import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:job_seeker_frontend/dto/register_dto.dart';
import 'package:job_seeker_frontend/services/auth_service.dart';
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
    final dto = RegisterDto(
      fullName: fullName,
      email: email,
      password: password,
    );

    try {
      final user = await AuthService().register(dto);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign up thành công!")),
      );

      return user;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      return null;
    }
  }
}
