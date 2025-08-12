import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/update_password_view_model.dart';
import '../../../widgets/login/logout_and_no_result/primary_button.dart';


class UpdatePasswordScreen extends StatelessWidget {
  const UpdatePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var vm = Provider.of<UpdatePasswordViewModel>(context);
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const Align(
                alignment: Alignment.centerLeft,
                child: Text('Update Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
            const SizedBox(height: 26),
            _PasswordField(
              controller: oldCtrl,
              label: 'Old Password',
              obscureText: vm.oldObscure,
              onToggle: vm.toggleOldObscure,
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: newCtrl,
              label: 'New Password',
              obscureText: vm.newObscure,
              onToggle: vm.toggleNewObscure,
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: confirmCtrl,
              label: 'Confirm Password',
              obscureText: vm.confirmObscure,
              onToggle: vm.toggleConfirmObscure,
            ),
            const Spacer(),
            PrimaryButton(
              text: 'UPDATE',
              onPressed: () {
                vm.updatePassword(oldCtrl.text, newCtrl.text, confirmCtrl.text);
              },
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback onToggle;

  const _PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
