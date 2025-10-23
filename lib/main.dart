// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ... các import khác của bạn ...
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/view_models/user/change_password_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/chat_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/forgot_password_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/login_chat_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/register_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/search_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/splash_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/zoom_view_model.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'myapp.dart';
import 'view_models/user/login_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => ZoomViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => ChangePasswordViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => LoginChatViewModel()),
      ],
      child: MyApp(),
    ),
  );
}
