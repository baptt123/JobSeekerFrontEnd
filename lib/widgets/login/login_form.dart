import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/user/login_view_model.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Email',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: vm.setEmail,
          controller: TextEditingController(text: vm.email),
          decoration: InputDecoration(
            hintText: 'Brandonnelouis@gmail.com',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Password',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: !vm.showPassword,
          onChanged: vm.setPassword,
          controller: TextEditingController(text: vm.password),
          decoration: InputDecoration(
            hintText: '••••••••',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            suffixIcon: IconButton(
              icon: Icon(vm.showPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => vm.toggleShowPassword(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
              value: vm.rememberMe,
              onChanged: (_) => vm.toggleRememberMe(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const Text('Remember me'),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot Password ?',
                style: TextStyle(color: Color(0xFF9C94D0), fontSize: 14),
              ),
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0,0)
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: vm.isLoading ? null : () => vm.login(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1445),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: vm.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('LOGIN', style: TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text('or', style: TextStyle(color: Colors.grey)),
            ),
            Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            icon: Image.asset('assets/icon/google logo.png', width: 24, height: 24), // Thêm icon google vào tài nguyên assets
            label: const Text('SIGN IN WITH GOOGLE', style: TextStyle(fontSize: 16, color: Color(0xFF1A1445))),
            onPressed: () => vm.signInWithGoogle(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2EEFE),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              foregroundColor: const Color(0xFF1A1445),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("You don't have an account yet? ", style: TextStyle(fontSize: 14, color: Colors.grey)),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Sign up',
                style: TextStyle(fontSize: 14, color: Color(0xFFFAA75F), decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
