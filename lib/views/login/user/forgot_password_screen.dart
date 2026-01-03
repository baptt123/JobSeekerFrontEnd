// lib/views/login/user/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/forgot_password_view_model.dart';

// 🔥 Định nghĩa màu chủ đạo (Tím)
const Color kPrimaryColor = Color(0xFF6C63FF);

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎨 Lấy thông tin Theme hiện tại để xử lý màu sắc
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Màu nền Card/Input: Tự động đổi giữa Trắng (Light) và Xám tối (Dark)
    final cardColor = theme.cardTheme.color ?? Colors.white;
    // Màu chữ chính: Tự động đổi giữa Đen (Light) và Trắng (Dark)
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;

    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      // GestureDetector để ẩn bàn phím khi chạm ra ngoài
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          // ✅ SỬA: Dùng màu nền từ theme (không gán cứng Colors.grey[50])
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              // ✅ SỬA: Icon tự động đổi màu Trắng/Đen
              icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Consumer<ForgotPasswordViewModel>(
                builder: (context, vm, _) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Icon minh họa
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor, // ✅ SỬA: Nền icon đổi màu theo theme
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.lock_reset_rounded, size: 50, color: kPrimaryColor),
                    ),
                    const SizedBox(height: 32),

                    // 2. Tiêu đề & Mô tả
                    Text(
                      "Quên mật khẩu?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color, // ✅ SỬA: Màu chữ tiêu đề
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Nhập email đã đăng ký. Hệ thống sẽ cấp lại một mật khẩu mới và gửi vào email của bạn.",
                      textAlign: TextAlign.center,
                      // ✅ SỬA: Màu chữ mô tả nhạt hơn chút trong Dark mode
                      style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey,
                          fontSize: 15,
                          height: 1.5
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 3. Form nhập liệu
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                        child: Text(
                          "Địa chỉ Email",
                          style: TextStyle(
                              color: textColor, // ✅ SỬA: Màu chữ nhãn
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: cardColor, // ✅ SỬA: Nền ô nhập liệu
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: vm.emailController,
                        keyboardType: TextInputType.emailAddress,
                        // ✅ SỬA: Màu chữ người dùng nhập
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: "example@gmail.com",
                          hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                          prefixIcon: const Icon(Icons.email_outlined, color: kPrimaryColor),
                          filled: true,
                          fillColor: cardColor, // ✅ SỬA: Màu nền bên trong TextField
                          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
                          ),
                        ),
                      ),
                    ),

                    // 4. Thông báo Lỗi / Thành công
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: (vm.successMessage != null || vm.errorMessage != null)
                          ? Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: vm.successMessage != null
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: vm.successMessage != null
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              vm.successMessage != null ? Icons.check_circle_rounded : Icons.error_rounded,
                              color: vm.successMessage != null ? Colors.green : Colors.red,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                vm.successMessage ?? vm.errorMessage!,
                                style: TextStyle(
                                  // ✅ SỬA: Điều chỉnh màu chữ thông báo để dễ đọc trên nền tối
                                  color: vm.successMessage != null
                                      ? (isDark ? Colors.greenAccent : Colors.green[800])
                                      : (isDark ? Colors.redAccent : Colors.red[800]),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 32),

                    // 5. Nút Gửi
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: vm.isLoading ? null : vm.submitForgotPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        child: vm.isLoading
                            ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                            : const Text(
                          "Lấy mật khẩu mới",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 6. Quay lại đăng nhập
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ✅ SỬA: Màu chữ "Đã nhận được..."
                        Text("Đã nhận được mật khẩu? ", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            "Đăng nhập ngay",
                            style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}