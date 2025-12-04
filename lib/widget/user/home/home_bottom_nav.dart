// lib/widget/user/home/home_bottom_nav.dart
import 'package:flutter/material.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const HomeBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap, // Gọi hàm callback khi nhấn
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF008080),
      unselectedItemColor: Colors.grey.shade500,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Saved'),
        BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Applied'), // Hoặc dùng làm trang CV Generator
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Message'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}