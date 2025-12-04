import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/login_view_model.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Gọi AutoLogin để check nếu user đã từng đăng nhập
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginViewModel>().autoLogin(context);
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi bấm nút "Về trang chủ"
  void _onBackToHome() {
    // Kiểm tra xem có trang nào nằm dưới không (thường là trang Home Guest)
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Đóng Login, quay về trang trước
    } else {
      // Trường hợp hiếm: Vào thẳng Login mà không qua Home -> Mới cần push
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe ViewModel
    final vm = context.read<LoginViewModel>();
    // Lắng nghe isLoading để hiển thị vòng xoay
    final isLoading = context.select<LoginViewModel, bool>((vm) => vm.isLoading);

    final theme = Theme.of(context);
    final customColorScheme = theme.colorScheme.copyWith(
      primary: const Color(0xFF00C89C),
      secondary: const Color(0xFF0077B6),
      surface: const Color(0xFFF2F2F2),
    );

    return Scaffold(
      // ✅ AppBar trong suốt với nút Back xử lý đúng logic
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey),
          tooltip: 'Về trang chủ',
          onPressed: _onBackToHome, // Gọi hàm xử lý pop
        ),
        title: GestureDetector(
          onTap: _onBackToHome, // Bấm vào chữ cũng back được
          child: const Text(
            "Trang chủ",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/icon/logo.png', height: 150, width: 150), // Giảm size logo chút cho cân đối
                  const SizedBox(height: 40),
                  const Text(
                    "Mời bạn đăng nhập!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Hãy nhập thông tin của bạn ngay tại đây để đăng nhập",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Nút Google Login
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : () => vm.loginWithGoogle(context),
                    icon: Image.asset('assets/icon/google logo.png', height: 24),
                    label: const Text(
                      'Đăng nhập với Google',
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Hoặc đăng nhập bằng Email",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Input Email
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade500),
                      filled: true,
                      fillColor: customColorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input Password
                  TextField(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade500),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey.shade500,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: customColorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quên mật khẩu
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        'Quên mật khẩu?',
                        style: TextStyle(color: customColorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nút Đăng nhập
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => vm.login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                      context,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customColorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 40),

                  // Đăng ký
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                        children: [
                          const TextSpan(text: "Chưa có tài khoản? "),
                          TextSpan(
                            text: 'Đăng ký ngay tại đây',
                            style: TextStyle(
                              color: customColorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}