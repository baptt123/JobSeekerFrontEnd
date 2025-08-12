import 'package:flutter/material.dart';

class RememberForgotRow extends StatelessWidget {
  final bool rememberMe;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onForgotPasswordPressed;

  const RememberForgotRow({
    super.key,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onForgotPasswordPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: rememberMe,
          onChanged: onRememberMeChanged,
          activeColor: const Color(0xFF7F56D9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        const Text('Remember me'),
        const Spacer(),
        TextButton(
          onPressed: onForgotPasswordPressed,
          child: const Text(
            'Forgot Password ?',
            style: TextStyle(color: Color(0xFF5D5FEF)),
          ),
        ),
      ],
    );
  }
}
