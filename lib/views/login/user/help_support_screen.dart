import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trợ giúp & Hỗ trợ"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section: Liên hệ trực tiếp
          _buildSectionTitle("Liên hệ chúng tôi"),
          _buildSupportTile(
            context,
            title: "Hotline hỗ trợ",
            subtitle: "1900 1234 (8:00 - 17:00)",
            icon: Icons.phone_in_talk,
            onTap: () {
              // TODO: Thêm logic gọi điện (url_launcher)
              _showSnackBar(context, "Đang gọi tới tổng đài...");
            },
          ),
          _buildSupportTile(
            context,
            title: "Gửi Email",
            subtitle: "support@jobcv.com",
            icon: Icons.email,
            onTap: () {
              // TODO: Thêm logic mở email app
              _showSnackBar(context, "Đang mở ứng dụng Email...");
            },
          ),

          const SizedBox(height: 20),

          // Section: Thông tin & Hướng dẫn
          _buildSectionTitle("Thông tin & Hướng dẫn"),
          _buildSupportTile(
            context,
            title: "Câu hỏi thường gặp (FAQ)",
            icon: Icons.help_outline,
            showArrow: true,
            onTap: () {
              // Điều hướng đến trang FAQ hoặc mở webview
            },
          ),
          _buildSupportTile(
            context,
            title: "Điều khoản sử dụng",
            icon: Icons.description,
            showArrow: true,
            onTap: () {
              // Điều hướng đến trang Điều khoản
            },
          ),
          _buildSupportTile(
            context,
            title: "Chính sách bảo mật",
            icon: Icons.privacy_tip,
            showArrow: true,
            onTap: () {
              // Điều hướng đến trang Chính sách
            },
          ),

          const SizedBox(height: 20),

          // Section: Phản hồi
          _buildSectionTitle("Phản hồi"),
          _buildSupportTile(
            context,
            title: "Báo cáo sự cố",
            icon: Icons.bug_report,
            showArrow: true,
            onTap: () {
              // Mở form báo lỗi
            },
          ),

          const SizedBox(height: 30),

          // Version Info
          Center(
            child: Text(
              "Phiên bản 1.0.0",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget tiêu đề cho từng nhóm (Section)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // Widget hiển thị từng mục (Tile)
  Widget _buildSupportTile(
      BuildContext context, {
        required String title,
        String? subtitle,
        required IconData icon,
        required VoidCallback onTap,
        bool showArrow = false,
      }) {
    return Card(
      elevation: 0,
      color: Colors.transparent, // Để đồng bộ với theme sáng/tối
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: showArrow
            ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
            : null,
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}