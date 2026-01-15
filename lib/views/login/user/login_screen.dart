import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/login_view_model.dart';
import '../../../utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Thêm GlobalKey để quản lý Form và Validation
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Biến trạng thái để ẩn/hiện mật khẩu
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi bấm đăng nhập
  void _submitLogin(LoginViewModel vm) {
    // Xóa focus bàn phím
    FocusScope.of(context).unfocus();

    // Kích hoạt validation frontend (hiện đỏ nếu sai)
    if (_formKey.currentState!.validate()) {
      vm.login(
          _emailController.text.trim(),
          _passwordController.text,
          context
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<LoginViewModel>();
    final isLoading = context.select<LoginViewModel, bool>((vm) => vm.isLoading);

    return Scaffold(
      backgroundColor: Colors.white, // UI Change: Nền trắng
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form( // Bọc trong Form để dùng Validator
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Tiêu đề
                  const Text(
                    "Kết nối tìm việc làm",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary // UI Change: Màu tím chủ đạo
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tương lai của bạn bắt đầu từ đây.",
                    style: TextStyle(fontSize: 16, color: Colors.grey), // UI Change: Màu xám
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Toggle Login/Register
                  Container(
                    height: 50,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // UI Change: Nền toggle sáng
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Center(
                                child: Text("Đăng nhập",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/register'),
                            child: const Center(
                                child: Text("Đăng kí",
                                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600))
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Input Email
                  _buildLightTextField(
                    controller: _emailController,
                    label: "Email",
                    hintText: "Nhập email",
                    icon: Icons.email_outlined,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Vui lòng nhập email'; // Báo đỏ nếu trống
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Input Password
                  _buildLightTextField(
                    controller: _passwordController,
                    label: "Mật khẩu",
                    hintText: "Nhập mật khẩu",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Vui lòng nhập mật khẩu'; // Báo đỏ nếu trống
                      }
                      return null;
                    },
                  ),

                  // Quên mật khẩu
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
                      child: const Text("Quên mật khẩu?",
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submitLogin(vm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                          : const Text(
                          "Đăng nhập",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text("Hoặc", style: TextStyle(color: Colors.grey.shade500)),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Button
                  OutlinedButton.icon(
                    onPressed: () => vm.loginWithGoogle(context),
                    icon: Image.asset('assets/icon/google logo.png', height: 24),
                    label: const Text("Đăng nhập với Google",
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widget xây dựng Input Field sáng màu + Validation
  Widget _buildLightTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isVisible,
          style: const TextStyle(color: Colors.black87), // Chữ màu đen
          validator: validator, // Hook validation logic vào đây
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50], // Nền xám rất nhạt
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.7)),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade500,
              ),
              onPressed: onToggleVisibility,
            )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            // Border bình thường
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            // Border khi focus (màu tím)
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            // Border khi có lỗi (màu đỏ - Yêu cầu bắt buộc)
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
            errorStyle: const TextStyle(color: Colors.redAccent), // Chữ thông báo lỗi màu đỏ
          ),
        ),
      ],
    );
  }
}