import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/forgot_password_view_model.dart';
import '../../../widgets/login/forgotpassword/forgot_password_form.dart';

class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ForgotPasswordViewModel>(
      create: (_) => ForgotPasswordViewModel(),
      child: Scaffold(
        body: ForgotPasswordForm(),
      ),
    );
  }
}
