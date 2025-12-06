import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFF00C89C), // Màu chủ đạo của App
      elevation: 0,
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
        ),
      ),
      centerTitle: true,
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
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: onLoginPressed,
              icon: const Icon(Icons.login, color: Colors.white, size: 20),
              label: const Text(
                'Đăng nhập',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2), // Nền mờ
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}