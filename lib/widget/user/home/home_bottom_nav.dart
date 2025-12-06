import 'package:flutter/material.dart';

// ĐỊNH NGHĨA MÀU CHỦ ĐẠO
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.1), // ✅ Shadow ánh tím nhẹ
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

        selectedItemColor: kPrimaryColor, // ✅ Icon được chọn màu Tím
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

          // 2. SAVED
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: true,
              smallSize: 8,
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.bookmark_border),
            ),
            activeIcon: const Icon(Icons.bookmark),
            label: 'Đã lưu',
          ),

          // 3. CENTER TAB: TOOLS
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: currentIndex == 2
                    ? kPrimaryColor // ✅ Nền tím đậm khi chọn
                    : kPrimaryColor.withOpacity(0.1), // ✅ Nền tím nhạt khi không chọn
                shape: BoxShape.circle,
                boxShadow: currentIndex == 2
                    ? [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.4), // ✅ Shadow tím
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
                    : null,
              ),
              child: Icon(
                Icons.dashboard_customize_outlined,
                size: 26,
                color: currentIndex == 2 ? Colors.white : kPrimaryColor, // ✅ Icon tím
              ),
            ),
            label: '',
          ),

          // 4. MESSAGE
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$unreadMessagesCount'),
              isLabelVisible: unreadMessagesCount > 0,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              child: const Icon(Icons.chat_bubble_outline),
            ),
            activeIcon: Badge(
              label: Text('$unreadMessagesCount'),
              isLabelVisible: unreadMessagesCount > 0,
              backgroundColor: Colors.red,
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