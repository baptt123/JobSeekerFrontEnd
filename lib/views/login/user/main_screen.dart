// lib/views/login/user/main_screen.dart

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/views/login/user/ai_cv_creation_screen.dart';
import 'package:provider/provider.dart';

// Import ViewModels
import 'package:job_seeker_frontend/view_models/user/save_job_view_model.dart';
import 'package:job_seeker_frontend/view_models/user/notification_view_model.dart';

// Import Screens
import 'package:job_seeker_frontend/views/login/user/home_screen.dart';
import 'package:job_seeker_frontend/views/login/user/profile_screen.dart';
import 'package:job_seeker_frontend/views/login/user/save_job_screen.dart';
import 'package:job_seeker_frontend/widget/user/home/home_bottom_nav.dart';
import 'cv_template_selection_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình tương ứng với 5 tabs
  final List<Widget> _screens = [
    const HomeScreen(),
    const SavedJobsScreen(),
    const AiCvCreationScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Gọi API lấy dữ liệu ngay khi vào màn hình chính để cập nhật Badge
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. Tải danh sách Job đã lưu
      context.read<SavedJobsViewModel>().fetchSavedJobs();

      // 2. Tải thông báo (để lấy số lượng chưa đọc cho badge Message/Notification)
      context.read<NotificationViewModel>().fetchNotifications();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe số lượng tin chưa đọc từ NotificationViewModel
    // (Bạn có thể thay bằng MessageViewModel nếu có logic chat riêng)
    final unreadCount = context.select<NotificationViewModel, int>(
      (vm) => vm.unreadCount,
    );

    return Scaffold(
      // Dùng IndexedStack để giữ trạng thái các trang khi chuyển tab
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        // Truyền số lượng tin chưa đọc vào BottomBar
        // (Lưu ý: savedJobCount không cần truyền vì HomeBottomNav đã tự lắng nghe Provider bên trong)
        unreadMessagesCount: unreadCount,
      ),
    );
  }
}
