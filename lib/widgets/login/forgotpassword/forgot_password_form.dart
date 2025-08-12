import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/forgot_password_view_model.dart';

class ForgotPasswordForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ForgotPasswordViewModel>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          Text('Forgot Password?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('To reset your password, you need your email or mobile number that can be authenticated', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          TextField(
            onChanged: vm.setEmail,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 24),
          vm.loading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: vm.email.isEmpty ? null : vm.resetPassword,
              child: const Text('RESET PASSWORD'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BACK TO LOGIN'),
          ),
        ],
      ),
    );
  }
}
