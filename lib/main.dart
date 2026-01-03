// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import Services
import 'package:job_seeker_frontend/services/local_notification_service.dart';
import 'package:job_seeker_frontend/services/firebase_messaging_service.dart';

// Import ViewModels
import 'package:job_seeker_frontend/view_models/user/change_password_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/conversation_list_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/cv_generation_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/forgot_password_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/job_detail_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/login_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/manage_cv_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/notification_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/register_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/save_job_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/scan_pdf_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/search_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/theme_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/user_profile_view_model.dart';

import 'firebase_options.dart';
import 'myapp.dart';

/// Handler xử lý thông báo khi ứng dụng ở chế độ nền hoặc bị đóng
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔥 Background Message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // 1. Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Khởi tạo Local Notification cho banner foreground
  await LocalNotificationService.initialize();

  // 3. Đăng ký background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => ChangePasswordViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => ScanPdfViewModel()),
        ChangeNotifierProvider(create: (_) => CvGenerationViewModel()),
        ChangeNotifierProvider(create: (_) => JobDetailViewModel()),
        ChangeNotifierProvider(create: (_) => SavedJobsViewModel()),
        ChangeNotifierProvider(create: (_) => ConversationListViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => ManageCvViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}