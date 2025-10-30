// lib/widget/user/home/home_app_bar.dart

import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  // 1. Thêm callback để nhận hàm từ bên ngoài
  final VoidCallback onFilterPressed;

  // 2. Cập nhật constructor để yêu cầu callback này
  const HomeAppBar({
    Key? key,
    required this.onFilterPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF008080),
      elevation: 0,
      title: const Text(
        'Mừng bạn trở lại 👋',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Xử lý logic thông báo
          },
        ),
        IconButton(
          icon: const Icon(Icons.tune, color: Colors.white),
          // 3. Gọi callback khi nhấn nút
          onPressed: onFilterPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}