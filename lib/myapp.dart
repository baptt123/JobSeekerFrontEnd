// lib/main.dart (hoặc my_app.dart)

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/views/login/user/login_screen.dart';
import 'package:job_seeker_frontend/views/login/test/cv_generator_screen.dart';
import 'package:job_seeker_frontend/views/login/user/change_password_screen.dart';
import 'package:job_seeker_frontend/views/login/user/forgot_password_screen.dart';
import 'package:job_seeker_frontend/views/login/user/home_screen.dart';
import 'package:job_seeker_frontend/views/login/user/place_screen.dart';
import 'package:job_seeker_frontend/views/login/user/register_screen.dart';
import 'package:job_seeker_frontend/views/login/user/search_screen.dart';
// Đảm bảo đường dẫn này đúng với vị trí file RoomScreen của bạn
import 'package:job_seeker_frontend/views/login/user/zoom_create_meeting_screen.dart';
Future<void> main() async {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Geoapify Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PlacesScreen(),
    );
  }
}

