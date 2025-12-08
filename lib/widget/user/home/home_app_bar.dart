import 'package:flutter/material.dart';

// ĐỊNH NGHĨA MÀU CHỦ ĐẠO
const Color kPrimaryColor = Color(0xFF6C63FF);

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Các callback để xử lý sự kiện từ bên ngoài truyền vào
  final VoidCallback onMenuPressed;
  final VoidCallback onFilterPressed;
  final VoidCallback onChatPressed;
  final VoidCallback onLoginPressed;
  final bool isUser; // Biến kiểm tra trạng thái đăng nhập

  const HomeAppBar({
    Key? key,
    required this.onMenuPressed,
    required this.onFilterPressed,
    required this.onChatPressed,
    required this.onLoginPressed,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryColor, // ✅ Đổi sang màu Tím
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        tooltip: 'Menu',
        onPressed: onMenuPressed, // Mở Drawer
      ),
      title: const Text(
        'Job Seeker',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        // 1. Nút Filter
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          tooltip: 'Bộ lọc',
          onPressed: onFilterPressed,
        ),

        // 2. Nút Chat (Chỉ hiện khi là User)
        if (isUser)
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            tooltip: 'Tin nhắn',
            onPressed: onChatPressed,
          ),

        // 3. Nút Đăng nhập (Chỉ hiện khi là Guest)
        if (!isUser)
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Căn lề phải rộng hơn chút cho đẹp
            child: Center(
              child: TextButton.icon(
                onPressed: onLoginPressed,
                icon: const Icon(Icons.login, color: Colors.white, size: 18),
                label: const Text(
                  'Đăng nhập',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2), // Nền mờ trên nền Tím
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Bo tròn dạng viên thuốc
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
