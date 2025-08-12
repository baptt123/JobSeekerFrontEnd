import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/splash_view_model.dart';

import '../../../widgets/login/logo/logo_widget.dart';
import '../../../widgets/login/splash/welcome_widget.dart';


class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SplashViewModel>(
      builder: (context, splashVM, child) {
        if (!splashVM.isCompleted) {
          // Sau 2s chuyển sang Welcome màn hình
          Future.delayed(Duration(seconds: 2), () {
            splashVM.completeSplash();
          });

          return Container(
            color: Color(0xFF140087), // màu nền splash
            child: LogoWidget(),
          );
        } else {
          return WelcomeWidget();
        }
      },
    );
  }
}
