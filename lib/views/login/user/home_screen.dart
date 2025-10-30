// lib/views/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/views/login/user/search_screen.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/home_view_model.dart';
import '../../../widget/user/home/home_app_bar.dart';
import '../../../widget/user/home/home_bottom_nav.dart';
import '../../../widget/user/home/home_header.dart';
import '../../../widget/user/home/job_list.dart';
import '../../../widget/user/home/search_bar.dart';
import '../../../widget/user/home/search_title.dart';
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
      appBar: HomeAppBar(
        onFilterPressed: () => _showFilterScreen(context),
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

  // SỬA LẠI HÀM NÀY
  Widget _buildBody(BuildContext context, HomeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          // <-- 2. XÓA CONST Ở ĐÂY
          children: [
            const HomeHeader(),
            // <-- 3. XÓA CONST Ở ĐÂY
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              // <-- 4. BỌC SearchCard BẰNG GestureDetector
              child: GestureDetector(
                onTap: () {
                  // <-- 5. ĐIỀU HƯỚNG ĐẾN SearchScreen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 56, // Chiều cao chuẩn cho thanh tìm kiếm
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4), // Đổ bóng xuống dưới
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Text(
                        'Tìm kiếm công việc...', // Văn bản gợi ý
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