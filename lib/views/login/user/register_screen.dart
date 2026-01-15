// lib/views/login/user/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/register_view_model.dart';
import '../../../utils/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Các Controllers để quản lý dữ liệu nhập
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Biến trạng thái để ẩn/hiện mật khẩu
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    // Ẩn bàn phím khi người dùng bấm nút đăng ký
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final success = await context.read<RegisterViewModel>().register(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
                backgroundColor: Colors.green
            )
        );
        Navigator.pop(context); // Quay về màn hình đăng nhập
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegisterViewModel>();

    return Scaffold(
      backgroundColor: Colors.white, // UI Change: Nền trắng
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87), // UI Change: Icon back màu đen
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                    "Tạo tài khoản",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary // UI Change: Màu tím thương hiệu
                    )
                ),
                const SizedBox(height: 8),
                const Text(
                    "Tham gia TechConnect ngay hôm nay!",
                    style: TextStyle(fontSize: 16, color: Colors.grey) // UI Change: Màu xám
                ),
                const SizedBox(height: 40),

                // 1. Họ và tên
                _buildInput(
                  controller: _fullNameController,
                  label: "Họ và tên",
                  icon: Icons.person_outline,
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
                ),
                const SizedBox(height: 20),

                // 2. Email (Có regex check định dạng)
                _buildInput(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Vui lòng nhập email';
                    // Kiểm tra định dạng email cơ bản
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 3. Mật khẩu (Có check độ dài > 6 ký tự như backend yêu cầu)
                _buildInput(
                  controller: _passwordController,
                  label: "Mật khẩu",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isVisible: _isPasswordVisible,
                  onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu';
                    if (val.length < 6) return 'Mật khẩu phải từ 6 ký tự trở lên';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 4. Xác nhận mật khẩu (Kiểm tra khớp với mật khẩu trên)
                _buildInput(
                  controller: _confirmPasswordController,
                  label: "Xác nhận mật khẩu",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isVisible: _isConfirmPasswordVisible,
                  onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                    if (val != _passwordController.text) return 'Mật khẩu không khớp';
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Hiển thị thông báo lỗi từ ViewModel (nếu có)
                if (vm.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        vm.errorMessage!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 4,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: vm.isLoading
                        ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                        : const Text(
                        "Đăng ký",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget ô nhập liệu (Input field) - UI Change: Bright Style
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false, // Trạng thái hiển thị mật khẩu
    VoidCallback? onToggleVisibility, // Hàm bật/tắt hiển thị mật khẩu
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isVisible, // Logic ẩn hiện mật khẩu
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.black87), // Chữ đen
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50], // Nền sáng
            prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.7)), // Icon tím
            // Thêm nút con mắt nếu là trường mật khẩu
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
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300)), // Viền thường
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            // Viền khi focus đậm màu tím
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2)
            ),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1)
            ),
            // Kiểu chữ cho thông báo lỗi
            errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
            hintText: "Nhập $label",
            hintStyle: TextStyle(color: Colors.grey.shade400),
          ),
          validator: validator,
        ),
      ],
    );
  }
}