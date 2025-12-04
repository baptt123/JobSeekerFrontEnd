// lib/myapp.dart

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/utils/responsive_util.dart';
import 'package:job_seeker_frontend/view_models/user/theme_view_model.dart';
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
import 'package:job_seeker_frontend/views/login/user/setting_screen.dart';
import 'package:job_seeker_frontend/views/login/user/splash_screen.dart';
import 'package:job_seeker_frontend/views/login/user/zoom_create_meeting_screen.dart';
import 'package:provider/provider.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeVM, child) {
        return MaterialApp(
          title: 'Job Seeker App',
          debugShowCheckedModeBanner: false,

          // --- CẤU HÌNH THEME ---
          themeMode: themeVM.themeMode,

          // 1. Theme Sáng (Light)
          theme: ThemeData(
            primarySwatch: Colors.teal,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF9F9F9),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF00C89C),
              foregroundColor: Colors.white,
            ),
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal)
                .copyWith(secondary: const Color(0xFF0077B6)),
          ),

          // 2. Theme Tối (Dark)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF00C89C),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F1F1F),
              foregroundColor: Colors.white,
            ),
            // ✅ ĐÃ SỬA LỖI: Dùng CardThemeData thay vì CardTheme
            cardTheme: const CardThemeData(
              color: Color(0xFF303030),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00C89C),
              secondary: Color(0xFF0077B6),
            ),
          ),

          builder: (context, child) {
            return ResponsiveUtil.buildResponsiveBreakpoints(child);
          },

          home: const SplashScreen(),

          routes: {
            '/login': (_) => const LoginScreen(),
            '/home': (_) => const MainScreen(),
            '/settings': (_) => const SettingsScreen(),
            '/zoom': (_) => const ZoomCreateMeetingScreen(),
            '/register': (_) => const RegisterScreen(),
            '/change_password': (_) => const ChangePasswordScreen(),
            '/forgot_password': (_) => const ForgotPasswordScreen(),
            '/search': (_) => const SearchScreen(),
            '/scan_pdf': (_) => const ScanPdfScreen(),
            '/cv_generator': (_) => const CvTemplateSelectionScreen(),
            '/save_job': (_) => const SavedJobsScreen(),
            '/notification': (_) => NotificationScreen(),
            '/profile': (_) => const ProfileScreen(),
          },
        );
      },
    );
  }
}