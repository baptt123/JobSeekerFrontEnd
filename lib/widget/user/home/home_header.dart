// lib/widget/user/home/home_header.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/user-entity.dart';
import '../../../../view_models/user/notification_view_model.dart';
// Giả sử AppColors.primary là màu xanh ngọc #00C89C
import '../../../../utils/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final UserEntity? user;

  const HomeHeader({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem có user không
    final bool isGuest = user == null;
    final String name = user?.fullName ?? "Khách";
    final String? avatar = user?.avatarUrl;

    return Container(
      // Padding bottom lớn (80) để search bar có thể đè lên
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
      decoration: const BoxDecoration(
        color: Color(0xFF00C89C), // Hoặc AppColors.primary
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // --- AVATAR ---
            GestureDetector(
              onTap: () {
                // Nếu là guest bấm avatar cũng cho sang login
                if (isGuest) Navigator.pushNamed(context, '/login');
              },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                backgroundImage: (avatar != null && !isGuest)
                    ? NetworkImage(avatar)
                    : null,
                child: (avatar == null || isGuest)
                    ? const Icon(Icons.person, color: Color(0xFF00C89C))
                    : null,
              ),
            ),
            const SizedBox(width: 16),

            // --- TEXT INFO ---
            Expanded(
              child: isGuest
                  ? _buildGuestInfo(context) // Giao diện cho khách
                  : _buildUserInfo(name),    // Giao diện cho User
            ),

            // --- NOTIFICATION ICON ---
            // Chỉ hiện thông báo nếu đã đăng nhập (tuỳ logic của bạn, ở đây tôi để hiện luôn nhưng có thể ẩn nếu muốn)
            if (!isGuest)
              Consumer<NotificationViewModel>(
                builder: (_, vm, __) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/notification'),
                        icon: const Icon(Icons.notifications_none, color: Colors.white, size: 24),
                        constraints: const BoxConstraints(), // Thu gọn padding mặc định
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    if (vm.unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text(
                              '${vm.unreadCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                          ),
                        ),
                      )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  // Widget hiển thị khi ĐÃ ĐĂNG NHẬP
  Widget _buildUserInfo(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Chào mừng trở lại,", style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis
        ),
      ],
    );
  }

  // Widget hiển thị khi CHƯA ĐĂNG NHẬP (Guest)
  Widget _buildGuestInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Bạn chưa đăng nhập?", style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Đăng nhập / Đăng ký",
              style: TextStyle(
                  color: Color(0xFF00C89C),
                  fontWeight: FontWeight.bold,
                  fontSize: 14
              ),
            ),
          ),
        ),
      ],
    );
  }
}