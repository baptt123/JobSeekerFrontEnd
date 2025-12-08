// lib/myapp.dart
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/utils/global_keys.dart';
import 'package:job_seeker_frontend/views/login/user/cv_preview_screen.dart';
import 'package:job_seeker_frontend/views/login/user/manage_cv_screen.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/utils/app_colors.dart';
import 'package:job_seeker_frontend/view_models/user/theme_view_model.dart';
import 'package:job_seeker_frontend/utils/responsive_util.dart';

// Import các màn hình (giữ nguyên như cũ của bạn)
import 'package:job_seeker_frontend/views/login/user/splash_screen.dart';
import 'package:job_seeker_frontend/views/login/user/login_screen.dart';
import 'package:job_seeker_frontend/views/login/user/main_screen.dart';
import 'package:job_seeker_frontend/views/login/user/register_screen.dart';
import 'package:job_seeker_frontend/views/login/user/forgot_password_screen.dart';
import 'package:job_seeker_frontend/views/login/user/change_password_screen.dart';
import 'package:job_seeker_frontend/views/login/user/setting_screen.dart';
import 'package:job_seeker_frontend/views/login/user/search_screen.dart';
import 'package:job_seeker_frontend/views/login/user/scan_pdf_screen.dart';
import 'package:job_seeker_frontend/views/login/user/gemini_cv_screen.dart';
import 'package:job_seeker_frontend/views/login/user/save_job_screen.dart';
import 'package:job_seeker_frontend/views/login/user/notification_screen.dart';
import 'package:job_seeker_frontend/views/login/user/profile_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeVM, child) {
        return MaterialApp(
          navigatorKey: ManagingGlobalKey.navigatorKey,
          title: 'TechConnect',
          debugShowCheckedModeBanner: false,
          themeMode: themeVM.themeMode,

          // --- CẤU HÌNH LIGHT THEME ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.backgroundLight,
            fontFamily: 'Inter',
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            // ✅ FIX LỖI: Dùng CardThemeData
            cardTheme: const CardThemeData(
              color: AppColors.cardLight,
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.accent,
              surface: AppColors.cardLight,
            ),
          ),

          // --- CẤU HÌNH DARK THEME ---
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.backgroundDark,
            fontFamily: 'Inter',
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.backgroundDark,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            // ✅ FIX LỖI: Dùng CardThemeData
            cardTheme: const CardThemeData(
              color: AppColors.cardDark,
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              secondary: AppColors.accent,
              surface: AppColors.cardDark,
            ),
          ),

          builder: (context, child) {
            return ResponsiveUtil.buildResponsiveBreakpoints(child);
          },

          home: const SplashScreen(),

          // Giữ nguyên Routes của bạn
          routes: {
            '/login': (_) => const LoginScreen(),
            '/home': (_) => const MainScreen(),
            '/settings': (_) => const SettingsScreen(),
            '/register': (_) => const RegisterScreen(),
            '/change_password': (_) => const ChangePasswordScreen(),
            '/forgot_password': (_) => const ForgotPasswordScreen(),
            '/search': (_) => const SearchScreen(),
            '/scan_pdf': (_) => const ScanPdfScreen(),
            '/cv_generator': (_) => const GeminiCvScreen(),
            '/save_job': (_) => const SavedJobsScreen(),
            '/notification': (_) => const NotificationScreen(),
            '/profile': (_) => const ProfileScreen(),
            '/manage_cv': (_) => const ManageCvScreen(),
            '/cv_preview': (_) => const CvPreviewScreen(),
          },
        );
      },
    );
  }
}
