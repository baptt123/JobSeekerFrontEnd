// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/services/local_notification_service.dart';
import 'package:job_seeker_frontend/services/firebase_messaging_service.dart'; // [MỚI] Import
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
// ... (giữ nguyên các import view_models khác) ...
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'myapp.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Khởi tạo Local Notifications
  await LocalNotificationService.initialize();

  // 3. [MỚI] Khởi tạo Firebase Messaging Service
  // Bước này quan trọng để ĐĂNG KÝ TOPIC và lắng nghe sự kiện
  final firebaseMessagingService = FirebaseMessagingService();
  await firebaseMessagingService.initialize((RemoteMessage message) {
    // Callback khi nhận tin nhắn ở Foreground (ví dụ: cập nhật badge)
    print("Main: Nhận tin nhắn foreground: ${message.notification?.title}");
  });

  // 4. Đăng ký background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        // ... (giữ nguyên danh sách providers) ...
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
      child: MyApp(),
    ),
  );
}