// lib/views/home/home_screen.dart

import 'package:flutter/material.dart';
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
      ), // <-- Widget mới
      body: Consumer<HomeViewModel>(
        builder: (context, vm, child) {
          if (vm.state == HomeState.loading && vm.jobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.state == HomeState.error && vm.jobs.isEmpty) {
            return Center(child: Text('Đã xảy ra lỗi: ${vm.errorMessage}'));
          }
          return _buildBody(context, vm); // Giữ lại hàm _buildBody
        },
      ),
      bottomNavigationBar: const HomeBottomNav(), // <-- Widget mới
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel vm) {
    return SingleChildScrollView(
      controller: _scrollController, // Gán controller
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: const [
              HomeHeader(), // <-- Widget mới
              Positioned(
                top: 100,
                left: 20,
                right: 20,
                child: SearchCard(), // <-- Widget mới
              ),
            ],
          ),
          const SizedBox(height: 120),
          const SectionTitle('Available Jobs'), // <-- Widget mới
          const SizedBox(height: 16),
          JobsList(vm: vm), // <-- Widget mới (truyền vm)
          // Hiển thị vòng quay khi tải thêm
          if (vm.isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  void _showFilterScreen(BuildContext context) {
    // Lấy VM hiện tại
    final vm = context.read<HomeViewModel>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Cho phép sheet cao
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // Cung cấp HomeViewModel cho FilterScreen
        // để nó có thể đọc filter cũ và gọi hàm apply/clear
        return ChangeNotifierProvider.value(
          value: vm,
          child: const FilterScreen(),
        );
      },
    );
  }
}
