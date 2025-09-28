// main.dart hoặc my_app.dart
import 'package:job_seeker_frontend/utils/responsive_util.dart'; // Đảm bảo bạn đã import file util
import 'package:job_seeker_frontend/views/login/extra_screen/add_experience/add_experience_screen.dart';
import 'package:job_seeker_frontend/views/login/extra_screen/add_experience/add_skill/add_skill_screen.dart';
import 'package:job_seeker_frontend/views/login/login_screen.dart';
import 'package:job_seeker_frontend/views/login/logout/logout_screen.dart';
import 'package:job_seeker_frontend/views/login/extra_screen/add_experience/no_result/no_result_screen.dart';
import 'package:job_seeker_frontend/views/login/extra_screen/add_experience/setting/setting_screen.dart';
import 'package:job_seeker_frontend/views/login/splash/splash_screen.dart';
import 'package:job_seeker_frontend/views/login/update_password/update_password_screen.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Seeker ',
      debugShowCheckedModeBanner: false,

      // SỬA Ở ĐÂY: Gọi phương thức tĩnh từ lớp ResponsiveUtil
      // và truyền cả context và widget.
      builder: (context, widget) => ResponsiveUtil.buildResponsiveBreakpoints(widget),
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.deepPurple,
      ),
      home: LoginScreen(),
    );
  }
}