// lib/widget/user/home/home_bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/save_job_view_model.dart'; // ✅ Import ViewModel

const Color kPrimaryColor = Color(0xFF6C63FF);

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int unreadMessagesCount; // Nhận số tin nhắn chưa đọc từ MainScreen

  const HomeBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.unreadMessagesCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🔥 Lắng nghe số lượng Job đã lưu trực tiếp từ ViewModel
    final savedJobsVM = context.watch<SavedJobsViewModel>();
    final int savedCount = savedJobsVM.savedJobs.length;

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

          // 2. SAVED (🔥 Đã cập nhật logic Badge)
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$savedCount'),
              // ✅ Chỉ hiện khi có job đã lưu (> 0)
              isLabelVisible: savedCount > 0,
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              child: const Icon(Icons.bookmark_border),
            ),
            activeIcon: Badge(
              label: Text('$savedCount'),
              isLabelVisible: savedCount > 0,
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              child: const Icon(Icons.bookmark),
            ),
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

          // 4. MESSAGE (🔥 Đã cập nhật logic Badge)
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$unreadMessagesCount'),
              // ✅ Chỉ hiện khi có tin nhắn mới (> 0)
              isLabelVisible: unreadMessagesCount > 0,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              child: const Icon(Icons.chat_bubble_outline),
            ),
            activeIcon: Badge(
              label: Text('$unreadMessagesCount'),
              isLabelVisible: unreadMessagesCount > 0,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              child: const Icon(Icons.chat_bubble),
            ),
            label: 'Tin nhắn',
          ),

          // 5. PROFILE
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}