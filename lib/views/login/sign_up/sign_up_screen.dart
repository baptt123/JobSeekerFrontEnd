import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/sign_up_view_model.dart';
import '../../../widgets/login/signup/input_field.dart';
import '../../../widgets/login/signup/remeber_forgot_row.dart';
import '../../../widgets/login/signup/sign_up_button.dart';
import '../../../widgets/login/signup/social_sign_up_button.dart';


class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SignupViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Create an Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF131246),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),

              // Full name input field
              InputField(
                label: 'Full name',
                hintText: 'Brandone Louis',
                onChanged: vm.setFullName,
                obscureText: false,
              ),
              const SizedBox(height: 20),

              // Email input field
              InputField(
                label: 'Email',
                hintText: 'Brandonelouis@gmail.com',
                onChanged: vm.setEmail,
                obscureText: false,
              ),
              const SizedBox(height: 20),

              // Password input field with obscure toggle
              InputField(
                label: 'Password',
                hintText: '••••••••••',
                onChanged: vm.setPassword,
                obscureText: !vm.isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(vm.isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: vm.togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 18),

              // Remember me checkbox & forgot password button
              RememberForgotRow(
                rememberMe: vm.rememberMe,
                onRememberMeChanged: vm.setRememberMe,
                onForgotPasswordPressed: () {
                  // TODO: Implement forgot password action
                },
              ),
              const SizedBox(height: 16),

              // Sign up button
              SignUpButton(
                onPressed: () async {
                  final user = await vm.signUp(context);
                  if (user != null) {
                    // TODO: điều hướng sang màn hình khác (Home / Login)
                  }
                },
              ),
              const SizedBox(height: 16),

              // Sign up with Google button
              SocialSignUpButton(
                label: 'SIGN UP WITH GOOGLE',
                onPressed: () {
                  // TODO: Implement Google sign up
                },
                assetImagePath: 'assets/icon/google logo.png',
              ),
              const SizedBox(height: 24),

              // Sign in redirect text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You don’t have an account yet? '),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to sign in screen
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Color(0xFFF99C1E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
