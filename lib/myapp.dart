// lib/myapp.dart

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/utils/responsive_util.dart';
import 'package:job_seeker_frontend/views/login/test/scan_pdf_screen.dart';
import 'package:job_seeker_frontend/views/login/user/change_password_screen.dart';
import 'package:job_seeker_frontend/views/login/user/cv_generation_view_screen.dart';
import 'package:job_seeker_frontend/views/login/user/cv_template_selection_screen.dart';
import 'package:job_seeker_frontend/views/login/user/forgot_password_screen.dart';
// import 'package:job_seeker_frontend/views/login/user/home_screen.dart'; // Bỏ import cũ này nếu không dùng trực tiếp
import 'package:job_seeker_frontend/views/login/user/login_screen.dart';
import 'package:job_seeker_frontend/views/login/user/main_screen.dart'; // ✅ Import MainScreen
import 'package:job_seeker_frontend/views/login/user/notification_screen.dart';
import 'package:job_seeker_frontend/views/login/user/profile_screen.dart';
import 'package:job_seeker_frontend/views/login/user/register_screen.dart';
import 'package:job_seeker_frontend/views/login/user/save_job_screen.dart';
import 'package:job_seeker_frontend/views/login/user/search_screen.dart';
import 'package:job_seeker_frontend/views/login/user/splash_screen.dart';
import 'package:job_seeker_frontend/views/login/user/zoom_create_meeting_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Seeker App',
      debugShowCheckedModeBanner: false, // Tắt banner debug cho đẹp
      theme: ThemeData(primarySwatch: Colors.blue),

      builder: (context, child) {
        return ResponsiveUtil.buildResponsiveBreakpoints(child);
      },

      // ✅ 1. Đặt màn hình khởi động là SplashScreen
      home: const SplashScreen(),

      routes: {
        '/login': (_) => LoginScreen(),
        '/zoom': (_) => ZoomCreateMeetingScreen(),
        '/register': (_) => RegisterScreen(),
        '/change_password': (_) => ChangePasswordScreen(),
        '/forgot_password': (_) => ForgotPasswordScreen(),

        // ✅ 2. Route '/home' trỏ về MainScreen (chứa BottomNav)
        '/home': (_) => const MainScreen(),

        '/search': (_) => SearchScreen(),
        '/scan_pdf': (_) => ScanPdfScreen(),
        '/cv_generator': (_) => CvTemplateSelectionScreen(),
        '/save_job': (_) => SavedJobsScreen(),
        '/notification': (_) => NotificationScreen(),
        '/profile': (_) => ProfileScreen(),
      },
    );
  }
}

// Bạn có thể xóa class MainMenu cũ đi nếu không còn dùng nữa để code gọn gàng.