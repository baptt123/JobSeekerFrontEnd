import 'package:job_seeker_frontend/view_models/user/add_education_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/add_experience_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/add_skill_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/chat_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/filter_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/forgot_password_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/messages_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/notification_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/profile_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/save_jobs_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/search_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/sign_up_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/splash_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/upload_cv_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/logout_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/no_result_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/setting_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/update_password_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'myapp.dart';
import 'view_models/user/login_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => UploadCVViewModel()),
        ChangeNotifierProvider(create: (_) => SavedJobsViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => MessagesViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => AddSkillViewModel()),
        ChangeNotifierProvider(create: (_) => AddEducationViewModel()),
        ChangeNotifierProvider(create: (_) => AddExperienceViewModel()),
        ChangeNotifierProvider(create: (_) => FilterViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => LogoutViewModel()),
        ChangeNotifierProvider(create: (_) => UpdatePasswordViewModel()),
        ChangeNotifierProvider(create: (_) => NoResultsViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}
