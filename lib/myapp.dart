// lib/main.dart (hoặc my_app.dart)

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/views/login/login_screen.dart';
import 'package:job_seeker_frontend/views/login/test/cv_generator_screen.dart';
// Đảm bảo đường dẫn này đúng với vị trí file RoomScreen của bạn
import 'package:job_seeker_frontend/views/login/zoom_meeting/zoom_create_meeting_screen.dart';
Future<void> main() async {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const Scaffold(
          body: Center(child: Text('Welcome Home!')),
        ),
      },
    );
  }
}

