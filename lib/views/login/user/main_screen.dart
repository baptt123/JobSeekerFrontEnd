// lib/views/login/user/main_screen.dart (TẠO MỚI)

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/views/login/user/conversation_list_screen.dart';
import 'package:job_seeker_frontend/views/login/user/home_screen.dart';
import 'package:job_seeker_frontend/views/login/user/profile_screen.dart';
import 'package:job_seeker_frontend/views/login/user/save_job_screen.dart';
import 'package:job_seeker_frontend/widget/user/home/home_bottom_nav.dart';

// Import trang Applied hoặc CV Generator tùy ý bạn
// Ví dụ dùng trang CV Template cho tab giữa
import 'cv_template_selection_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình tương ứng với 5 tabs
  final List<Widget> _screens = [
    const HomeScreen(),              // Tab 0: Home
    const SavedJobsScreen(),         // Tab 1: Saved Jobs
    const CvTemplateSelectionScreen(), // Tab 2: CV / Applied (Thay đổi tùy ý)
    const ConversationListScreen(),  // Tab 3: Message
    const ProfileScreen(),           // Tab 4: Profile
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