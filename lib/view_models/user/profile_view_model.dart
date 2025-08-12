import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  String location = 'California, USA';
  int followers = 120000;
  int following = 23000;

  // ✅ Dùng dynamic để chứa cả String và List<String>
  List<Map<String, dynamic>> sections = [
    {
      'title': 'About me',
      'items': <String>[]
    },
    {
      'title': 'Work experience',
      'items': <String>[]
    },
  ];

  void editProfile() {
    // handle edit
  }
}
