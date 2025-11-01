// lib/views/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/views/login/user/search_screen.dart';
import 'package:provider/provider.dart';

// ✅ 1. IMPORT MÀN HÌNH DANH SÁCH CHAT

import '../../../view_models/user/home_view_model.dart';
// import '../../../widget/user/home/home_app_bar.dart'; // Không dùng nữa
import '../../../widget/user/home/home_bottom_nav.dart';
import '../../../widget/user/home/home_header.dart';
import '../../../widget/user/home/job_list.dart';
// import '../../../widget/user/home/search_bar.dart'; // Không dùng nữa
import '../../../widget/user/home/search_title.dart';
import 'conversation_list_screen.dart';
import 'filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Bạn nên gọi fetchJobs ở đây nếu nó chưa được gọi trong ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchJobs();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final vm = context.read<HomeViewModel>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      vm.fetchMoreJobs();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      // ✅ 2. SỬ DỤNG APPBAR TIÊU CHUẨN ĐỂ THÊM NÚT CHAT
      appBar: AppBar(
        // Màu nền của HomeHeader (hoặc màu bạn muốn)
        backgroundColor: const Color(0xFF00C89C),
        elevation: 0,
        title: const Text(
            'Trang chủ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Cho nút back (nếu có)
        actions: [
          // Nút Filter bạn đã có
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: 'Lọc công việc',
            onPressed: () => _showFilterScreen(context),
          ),

          // ✅ 3. NÚT MỚI ĐỂ MỞ DANH SÁCH CHAT
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            tooltip: 'Tin nhắn',
            onPressed: () {
              // Điều hướng đến màn hình danh sách chat
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConversationListScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Consumer<HomeViewModel>(
        builder: (context, vm, child) {
          if (vm.state == HomeState.loading && vm.jobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.state == HomeState.error && vm.jobs.isEmpty) {
            return Center(child: Text('Đã xảy ra lỗi: ${vm.errorMessage}'));
          }
          return _buildBody(context, vm);
        },
      ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }

  // Widget _buildBody (Giữ nguyên code của bạn)
  Widget _buildBody(BuildContext context, HomeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // HomeHeader của bạn
            const HomeHeader(),
            // Thanh tìm kiếm
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Text(
                        'Tìm kiếm công việc...',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 120),
        const SectionTitle('Available Jobs'),
        const SizedBox(height: 16),
        Expanded(
          child: JobsList(
            scrollController: _scrollController,
          ),
        ),
        if (vm.isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  // void _showFilterScreen (Giữ nguyên code của bạn)
  void _showFilterScreen(BuildContext context) {
    final vm = context.read<HomeViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return ChangeNotifierProvider.value(
          value: vm,
          child: const FilterScreen(),
        );
      },
    );
  }
}