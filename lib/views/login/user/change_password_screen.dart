import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/change_password_view_model.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // Sử dụng ChangeNotifierProvider để cung cấp ViewModel cho cây widget
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewModel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        body: Consumer<ChangePasswordViewModel>(
          builder: (context, vm, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: vm.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Đổi mật khẩu',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy nhập mật khẩu cũ và mật khẩu mới của bạn để cập nhật thông tin.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    // Bạn có thể thêm ảnh vào đây
                    // Image.asset('assets/your_image.png', height: 200),
                    const SizedBox(height: 40),

                    // Old Password Field
                    _buildPasswordTextField(
                      controller: vm.oldPasswordController,
                      labelText: 'Mật khẩu cũ',
                      isVisible: _isOldPasswordVisible,
                      toggleVisibility: () {
                        setState(() {
                          _isOldPasswordVisible = !_isOldPasswordVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // New Password Field
                    _buildPasswordTextField(
                      controller: vm.newPasswordController,
                      labelText: 'Mật khẩu mới',
                      isVisible: _isNewPasswordVisible,
                      toggleVisibility: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Confirm New Password Field
                    _buildPasswordTextField(
                        controller: vm.confirmPasswordController,
                        labelText: 'Xác nhận mật khẩu mới',
                        isVisible: _isConfirmPasswordVisible,
                        toggleVisibility: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Làm ơn xác nhận mật khẩu mới';
                          }
                          if (value != vm.newPasswordController.text) {
                            return 'Mật khẩu không khớp';
                          }
                          return null;
                        }
                    ),

                    const SizedBox(height: 40),

                    // Save Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: vm.isLoading ? null : () => vm.updatePassword(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E8C83), // Teal color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: vm.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Save',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget helper để tránh lặp code cho các TextFormField
  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String labelText,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E8C83), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: toggleVisibility,
        ),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Thông tin này không được để trống';
        }
        if (value.length < 6) {
          return 'Mật khẩu phải có ít nhất 6 kí tự ';
        }
        return null;
      },
    );
  }
}