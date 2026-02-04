import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/utils/global_keys.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/utils/app_colors.dart';
import 'package:job_seeker_frontend/view_models/user/theme_view_model.dart';
import 'package:job_seeker_frontend/utils/responsive_util.dart';

// Import các màn hình (giữ nguyên import của bạn)
import 'package:job_seeker_frontend/views/login/user/splash_screen.dart';
import 'package:job_seeker_frontend/views/login/user/login_screen.dart';
import 'package:job_seeker_frontend/views/login/user/main_screen.dart';
import 'package:job_seeker_frontend/views/login/user/register_screen.dart';
import 'package:job_seeker_frontend/views/login/user/forgot_password_screen.dart';
import 'package:job_seeker_frontend/views/login/user/change_password_screen.dart';
import 'package:job_seeker_frontend/views/login/user/setting_screen.dart';
import 'package:job_seeker_frontend/views/login/user/search_screen.dart';
import 'package:job_seeker_frontend/views/login/user/gemini_cv_screen.dart';
import 'package:job_seeker_frontend/views/login/user/save_job_screen.dart';
import 'package:job_seeker_frontend/views/login/user/notification_screen.dart';
import 'package:job_seeker_frontend/views/login/user/profile_screen.dart';
import 'package:job_seeker_frontend/views/login/user/manage_cv_screen.dart';
import 'package:job_seeker_frontend/views/login/user/cv_preview_screen.dart';

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

          // --- LIGHT THEME ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.backgroundLight,
            fontFamily: 'Inter',
            canvasColor: Colors.white, // Màu nền Drawer/Dropdown

            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),

            cardTheme: const CardThemeData(
              color: AppColors.cardLight,
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),

            // SỬA LỖI: Dùng DialogThemeData cho Flutter bản mới
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
            ),

            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.white,
              modalBackgroundColor: Colors.white,
            ),

            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
            ),

            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.accent,
              surface: AppColors.cardLight,
              onSurface: Colors.black87,
            ),
          ),

          // --- DARK THEME (Đã tối ưu) ---
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.backgroundDark, // Nền tối
            fontFamily: 'Inter',

            // Quan trọng: Đổi màu nền Drawer/Dropdown thành tối
            canvasColor: AppColors.backgroundDark,

            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.backgroundDark,
              foregroundColor: Colors.white,
              elevation: 0,
            ),

            cardTheme: const CardThemeData(
              color: AppColors.cardDark, // Card màu xám tối
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),

            // SỬA LỖI: Dùng DialogThemeData
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.cardDark,
              surfaceTintColor: Colors.transparent,
            ),

            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: AppColors.cardDark,
              modalBackgroundColor: AppColors.cardDark,
              surfaceTintColor: Colors.transparent,
            ),

            // Thanh điều hướng dưới cùng màu tối
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: AppColors.backgroundDark,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
            ),

            dividerTheme: const DividerThemeData(color: Colors.white12),

            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              secondary: AppColors.accent,
              surface: AppColors.cardDark,
              background: AppColors.backgroundDark,
              onBackground: Colors.white,
              onSurface: Colors.white,
            ),
          ),

          builder: (context, child) {
            return ResponsiveUtil.buildResponsiveBreakpoints(child);
          },

          home: const SplashScreen(),

          // Routes giữ nguyên
          routes: {
            '/login': (_) => const LoginScreen(),
            '/home': (_) => const MainScreen(),
            '/settings': (_) => const SettingsScreen(),
            '/register': (_) => const RegisterScreen(),
            '/change_password': (_) => const ChangePasswordScreen(),
            '/forgot_password': (_) => const ForgotPasswordScreen(),
            '/search': (_) => const SearchScreen(),
            // '/scan_pdf': (_) => ScanPdfScreen(),
            '/cv_generator': (_) => GeminiCvScreen(),
            '/save_job': (_) => const SavedJobsScreen(),
            '/notification': (_) => const NotificationScreen(),
            '/profile': (_) => const ProfileScreen(),
            '/manage_cv': (_) => ManageCvScreen(),
            '/cv_preview': (_) => CvPreviewScreen(localPath: '',),
          },
        );
      },
    );
  }
}