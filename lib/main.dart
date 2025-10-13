// main.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_seeker_frontend/services/web_socket_service.dart';

// 👇 Import CallViewModel mới
import 'package:job_seeker_frontend/view_models/user/chat_view_model.dart';

// ... các import khác của bạn ...
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/view_models/user/forgot_password_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/logout_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/sign_up_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/splash_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/update_password_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/upload_cv_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/zoom_view_model.dart';
import 'package:provider/provider.dart';
import 'myapp.dart';
import 'view_models/user/login_view_model.dart';


Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => UploadCVViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => LogoutViewModel()),
        ChangeNotifierProvider(create: (_) => UpdatePasswordViewModel()),
        ChangeNotifierProvider(create: (_) => ZoomViewModel()),
      ],
      child:  MyApp(),
    ),
  );
}
