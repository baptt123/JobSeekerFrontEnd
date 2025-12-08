// lib/widget/user/home/home_header.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/user-entity.dart';
import '../../../../view_models/user/notification_view_model.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class HomeHeader extends StatelessWidget {
  final UserEntity? user;

  const HomeHeader({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isGuest = user == null;
    final String name = user?.fullName ?? "";
    final String? avatar = user?.avatarUrl;

    // Kiểm tra URL avatar hợp lệ
    final bool isValidAvatar = avatar != null &&
        avatar.isNotEmpty &&
        avatar.startsWith('http');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
      decoration: const BoxDecoration(
        color: kPrimaryColor,
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
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (isValidAvatar && !isGuest)
                      ? NetworkImage(avatar!)
                      : null,
                  child: (!isValidAvatar || isGuest)
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // --- TÊN USER / KHÁCH ---
            Expanded(
              child: isGuest
                  ? _buildGuestHeader(context)
                  : _buildUserHeader(name),
            ),

            // --- NOTIFICATION ICON (🔥 Logic Badge mới) ---
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
                    // ✅ Chỉ hiện Badge khi có thông báo chưa đọc
                    if (vm.unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 1.5)) // Viền trắng cho đẹp
                          ),
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

  Widget _buildUserHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Chào mừng,", style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildGuestHeader(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/login'),
        icon: const Icon(Icons.login, size: 18, color: kPrimaryColor),
        label: const Text("Đăng nhập ngay", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: kPrimaryColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}