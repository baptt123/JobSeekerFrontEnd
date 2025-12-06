// lib/views/login/user/main_screen.dart

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/views/login/user/conversation_list_screen.dart';
import 'package:job_seeker_frontend/views/login/user/home_screen.dart';
import 'package:job_seeker_frontend/views/login/user/profile_screen.dart';
import 'package:job_seeker_frontend/views/login/user/save_job_screen.dart';
import 'package:job_seeker_frontend/widget/user/home/home_bottom_nav.dart';

import 'cv_template_selection_screen.dart';

// ĐIỀU CHỈNH: Import đúng đường dẫn file vừa tạo ở bước trước

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình tương ứng với 5 tabs
  final List<Widget> _screens = [
    const HomeScreen(),                // Tab 0: Home
    const SavedJobsScreen(),           // Tab 1: Saved Jobs
    const CvTemplateSelectionScreen(), // Tab 2: Tạo CV (Đã cập nhật)
    const ConversationListScreen(),    // Tab 3: Message
    const ProfileScreen(),             // Tab 4: Profile
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dùng IndexedStack để giữ trạng thái các trang khi chuyển tab
      // (ví dụ đang chat dở hoặc đang điền form CV thì không bị mất dữ liệu khi chuyển tab)
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}