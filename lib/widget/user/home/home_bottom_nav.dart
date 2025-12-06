import 'package:flutter/material.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  // Giả sử bạn nhận thêm số lượng tin nhắn chưa đọc từ bên ngoài vào
  final int unreadMessagesCount;

  const HomeBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.unreadMessagesCount = 3, // Ví dụ đang có 3 tin nhắn chưa đọc
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
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

        selectedItemColor: const Color(0xFF00C89C),
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

          // 2. SAVED (Có chấm đỏ nhỏ báo hiệu có Job mới phù hợp)
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: true, // Hiện chấm đỏ
              smallSize: 8, // Kích thước chấm nhỏ
              child: const Icon(Icons.bookmark_border),
            ),
            activeIcon: const Icon(Icons.bookmark),
            label: 'Đã lưu',
          ),

          // 3. CENTER TAB: TOOLS (CV, Gemini, Scan)
          // Làm icon này to hơn và nổi bật hẳn lên
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(12), // To hơn một chút
              decoration: BoxDecoration(
                color: currentIndex == 2
                    ? const Color(0xFF00C89C) // Khi chọn thì nền xanh đậm
                    : const Color(0xFF00C89C).withOpacity(0.1), // Không chọn thì nền nhạt
                shape: BoxShape.circle,
                boxShadow: currentIndex == 2
                    ? [ // Thêm shadow cho nút giữa khi được chọn
                  BoxShadow(
                    color: const Color(0xFF00C89C).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
                    : null,
              ),
              child: Icon(
                Icons.dashboard_customize_outlined, // Đổi icon thành dạng "Menu/Tool"
                size: 26,
                color: currentIndex == 2 ? Colors.white : const Color(0xFF00C89C),
              ),
            ),
            label: '', // Bỏ label text để icon giữa đứng một mình cho đẹp
          ),

          // 4. MESSAGE (Có số lượng tin nhắn)
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$unreadMessagesCount'), // Số tin nhắn
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