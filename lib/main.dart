// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ... các import khác của bạn ...
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/services/local_notification_service.dart';
import 'package:job_seeker_frontend/services/manage_cv_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/change_password_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/conversation_list_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/cv_generation_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/forgot_password_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/job_detail_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/notification_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/register_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/save_job_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/scan_pdf_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/search_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/theme_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/user_profile_view_model.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'myapp.dart';
import 'view_models/user/login_view_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// TOP-LEVEL FUNCTION: Bắt buộc phải là top-level (bên ngoài mọi class)
// để xử lý thông báo khi app đang ở trạng thái terminated (background).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Bạn có thể xử lý data message ở đây
  // Ví dụ: lưu vào local storage
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Khởi tạo Local Notifications
  await LocalNotificationService.initialize(); // <-- 2. Khởi tạo
  // Đăng ký background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await dotenv.load(fileName: ".env");
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
      child: MyApp(),
    ),
  );
}
