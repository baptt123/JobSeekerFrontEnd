import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/user-entity.dart';
import '../../../../view_models/user/notification_view_model.dart';

// ĐỊNH NGHĨA MÀU CHỦ ĐẠO (TÍM)
const Color kPrimaryColor = Color(0xFF6C63FF);

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
        color: kPrimaryColor, // ✅ Đổi sang màu Tím
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // --- AVATAR ---
            GestureDetector(
              onTap: () {
                if (isGuest) Navigator.pushNamed(context, '/login');
              },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                backgroundImage: (avatar != null && !isGuest)
                    ? NetworkImage(avatar)
                    : null,
                child: (avatar == null || isGuest)
                    ? const Icon(Icons.person, color: kPrimaryColor) // ✅ Icon tím
                    : null,
              ),
            ),
            const SizedBox(width: 16),

            // --- TEXT INFO ---
            Expanded(
              child: isGuest
                  ? _buildGuestInfo(context)
                  : _buildUserInfo(name),
            ),

            // --- NOTIFICATION ICON ---
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
                        constraints: const BoxConstraints(),
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
                  color: kPrimaryColor, // ✅ Chữ màu Tím
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