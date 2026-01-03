// lib/widget/user/home/home_bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../../view_models/user/save_job_view_model.dart'; // Có thể bỏ import này nếu không dùng savedJobsVM nữa

const Color kPrimaryColor = Color(0xFF6C63FF);

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int unreadMessagesCount;

  const HomeBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.unreadMessagesCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🔥 Đã xóa logic lấy savedCount để hiển thị badge

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,

        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey.shade400,

        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),

        items: [
          // 1. HOME
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),

          // 2. SAVED (✅ Đã xóa Badge)
          const BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Đã lưu',
          ),

          // 3. CENTER TAB: TOOLS
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: currentIndex == 2
                    ? kPrimaryColor
                    : kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: currentIndex == 2
                    ? [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
                    : null,
              ),
              child: Icon(
                Icons.dashboard_customize_outlined,
                size: 26,
                color: currentIndex == 2 ? Colors.white : kPrimaryColor,
              ),
            ),
            label: '',
          ),

          // 4. MESSAGE (✅ Đã xóa Badge)
          const BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle_outlined),
            activeIcon: Icon(Icons.supervised_user_circle),
            label: 'Hồ sơ',
          ),

          // 5. PROFILE
          const BottomNavigationBarItem(
            icon: Icon(Icons.support_outlined),
            activeIcon: Icon(Icons.support),
            label: 'Trợ giúp',
          ),
        ],
      ),
    );
  }
}