import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/forgot_password_view_model.dart';
import '../../../utils/app_colors.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.loginGradient),
          padding: const EdgeInsets.all(24),
          child: Consumer<ForgotPasswordViewModel>(
            builder: (context, vm, _) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_reset, size: 80, color: AppColors.accent),
                const SizedBox(height: 24),
                const Text("Reset Password", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text("Enter your email to receive reset instructions.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 40),

                TextField(
                  controller: vm.emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    hintText: "Email Address",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    prefixIcon: const Icon(Icons.email, color: Colors.white54),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),

                if (vm.successMessage != null) Text(vm.successMessage!, style: const TextStyle(color: Colors.greenAccent)),
                if (vm.errorMessage != null) Text(vm.errorMessage!, style: const TextStyle(color: Colors.redAccent)),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : vm.submitForgotPassword,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: vm.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Send Link", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}