import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/login_view_model.dart';
import '../../../view_models/user/theme_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt"),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // === PHẦN 1: GIAO DIỆN ===
          _buildSectionHeader("Giao diện & Hiển thị"),
          Consumer<ThemeViewModel>(
            builder: (context, themeVM, _) {
              return SwitchListTile(
                title: const Text("Chế độ tối (Dark Mode)"),
                subtitle: const Text("Giảm mỏi mắt và tiết kiệm pin"),
                secondary: Icon(
                  themeVM.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: themeVM.isDarkMode ? Colors.yellow : Colors.grey,
                ),
                value: themeVM.isDarkMode,
                onChanged: (val) {
                  themeVM.toggleTheme(val);
                },
              );
            },
          ),

          const Divider(),

          // === PHẦN 2: TÀI KHOẢN ===
          _buildSectionHeader("Tài khoản"),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: Colors.blue),
            title: const Text("Đổi mật khẩu"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/change_password');
            },
          ),

          // Bạn có thể thêm các mục khác như: Ngôn ngữ, Thông báo...

          const Divider(),

          // === PHẦN 3: HỆ THỐNG ===
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Đồng ý", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      // Gọi ViewModel để logout
      await context.read<LoginViewModel>().logout(context);
    }
  }
}