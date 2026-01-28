// lib/views/login/user/setting_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/theme_view_model.dart';
import '../../../view_models/user/login_view_model.dart';
import '../../../utils/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar sẽ tự động lấy màu từ appBarTheme trong MyApp
      appBar: AppBar(title: const Text("Cài đặt")),
      // Nền body sẽ tự động lấy scaffoldBackgroundColor (Dark/Light)
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            title: const Text("Chế độ tối"),
            // Icon sẽ tự động có màu trắng trong Dark Mode
            leading: const Icon(Icons.dark_mode),
            trailing: Consumer<ThemeViewModel>(
              builder: (_, vm, __) => Switch(
                activeColor: AppColors.primary,
                value: vm.isDarkMode,
                onChanged: vm.toggleTheme,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text("Đổi mật khẩu"),
            leading: const Icon(Icons.lock),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, '/change_password'),
          ),
          // ListTile(
          //   title: const Text("Đăng xuất"),
          //   leading: const Icon(Icons.logout, color: Colors.red),
          //   onTap: () => context.read<LoginViewModel>().logout(context),
          // ),
        ],
      ),
    );
  }
}