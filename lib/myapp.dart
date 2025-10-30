// // lib/main.dart (hoặc my_app.dart)
//
// import 'package:flutter/material.dart';
// import 'package:job_seeker_frontend/views/login/test/login_view_chat_screen.dart';
// import 'package:job_seeker_frontend/views/login/user/login_screen.dart';
// import 'package:job_seeker_frontend/views/login/test/cv_generator_screen.dart';
// import 'package:job_seeker_frontend/views/login/user/change_password_screen.dart';
// import 'package:job_seeker_frontend/views/login/user/forgot_password_screen.dart';
// import 'package:job_seeker_frontend/views/login/user/home_screen.dart';
// import 'package:job_seeker_frontend/views/login/user/register_screen.dart';
// import 'package:job_seeker_frontend/views/login/user/search_screen.dart';
//
// // Đảm bảo đường dẫn này đúng với vị trí file RoomScreen của bạn
// import 'package:job_seeker_frontend/views/login/user/zoom_create_meeting_screen.dart';
//
// Future<void> main() async {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Chat App Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
//         useMaterial3: true,
//       ),
//       home: const InputScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/utils/responsive_util.dart';
import 'package:job_seeker_frontend/views/login/test/chat_view_screen.dart';
import 'package:job_seeker_frontend/views/login/test/cv_generator_screen.dart';
import 'package:job_seeker_frontend/views/login/test/login_view_chat_screen.dart';
import 'package:job_seeker_frontend/views/login/test/scan_pdf_screen.dart';
import 'package:job_seeker_frontend/views/login/user/change_password_screen.dart';
import 'package:job_seeker_frontend/views/login/user/cv_generation_view_screen.dart';
import 'package:job_seeker_frontend/views/login/user/forgot_password_screen.dart';
import 'package:job_seeker_frontend/views/login/user/home_screen.dart';
import 'package:job_seeker_frontend/views/login/user/login_screen.dart';
import 'package:job_seeker_frontend/views/login/user/notification_screen.dart';
import 'package:job_seeker_frontend/views/login/user/register_screen.dart';
import 'package:job_seeker_frontend/views/login/user/save_job_screen.dart';
import 'package:job_seeker_frontend/views/login/user/search_screen.dart';
import 'package:job_seeker_frontend/views/login/user/zoom_create_meeting_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Seeker App',
      theme: ThemeData(primarySwatch: Colors.blue),

      // 5. Thêm thuộc tính 'builder' ở đây
      builder: (context, child) {
        // Gọi hàm tiện ích của bạn
        return ResponsiveUtil.buildResponsiveBreakpoints(child);
      },

      home: MainMenu(),
      // Giữ nguyên MainMenu của bạn
      routes: {
        // Giữ nguyên routes của bạn
        '/login': (_) => LoginScreen(),
        '/zoom': (_) => ZoomCreateMeetingScreen(),
        '/register': (_) => RegisterScreen(),
        '/change_password': (_) => ChangePasswordScreen(),
        '/forgot_password': (_) => ForgotPasswordScreen(),
        '/home': (_) => HomeScreen(),
        '/search': (_) => SearchScreen(),
        // '/chat': (_) => ChatViewScreen(),
        '/login_chat': (_) => LoginChatViewScreen(),
        '/cv_generator': (_) => InputCVGeneratorScreen(),
        '/scan_pdf': (_) => ScanPdfScreen(),
        '/cv_gemini': (_) => CvGenerationViewScreen(),
        '/save_job': (_) => SavedJobsScreen(),
        '/notification': (_) => NotificationScreen(),
      },
    );
  }
}

class MainMenu extends StatelessWidget {
  final List<Map<String, String>> _screens = [
    {'title': 'Login', 'route': '/login'},
    {'title': 'Splash', 'route': '/splash'},
    {'title': 'Zoom', 'route': '/zoom'},
    {'title': 'Register', 'route': '/register'},
    {'title': 'Change Password', 'route': '/change_password'},
    {'title': 'Forgot Password', 'route': '/forgot_password'},
    {'title': 'Home', 'route': '/home'},
    {'title': 'Search', 'route': '/search'},
    {'title': 'Chat', 'route': '/chat'},
    {'title': 'Login Chat', 'route': '/login_chat'},
    {'title': 'CV Generator', 'route': '/cv_generator'},
    {'title': ' Test Scan PDF', 'route': '/scan_pdf'},
    {'title': 'Create CV from Gemini', 'route': '/cv_gemini'},
    {'title': 'Test Save Job', 'route': '/save_job'},
    {'title': 'Test Notification', 'route': '/notification'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Seeker Main Menu')),
      body: ListView.builder(
        itemCount: _screens.length,
        itemBuilder: (context, index) {
          final item = _screens[index];
          return ListTile(
            title: Text(item['title']!),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, item['route']!),
          );
        },
      ),
    );
  }
}
