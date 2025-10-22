// lib/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/home_view_model.dart';
import '../../../widget/user/suggest_job_card.dart';
// Widget 'popular_job_card.dart' không còn cần thiết nữa

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
    // Thêm listener cho ScrollController
    _scrollController.addListener(_onScroll);

    // Tải dữ liệu ngay sau khi build xong
    // (ViewModel đã tự gọi khi khởi tạo, nhưng đây là 1 cách khác)
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<HomeViewModel>().fetchJobs();
    // });
  }

  void _onScroll() {
    final vm = context.read<HomeViewModel>();
    // Kiểm tra nếu cuộn gần đến cuối (ví dụ 90%
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Gọi hàm tải thêm
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
      appBar: _buildAppBar(),
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    // (Giữ nguyên code _buildAppBar như trước)
    return AppBar(
      backgroundColor: const Color(0xFF008080),
      elevation: 0,
      title: const Text(
        'Welcome Peter 👋',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.tune, color: Colors.white),
          onPressed: () {},
        ),
      ],
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
            children: [
              _buildHeader(context),
              Positioned(
                top: 100,
                left: 20,
                right: 20,
                child: _buildSearchCard(),
              ),
            ],
          ),
          const SizedBox(height: 120),
          _buildSectionTitle('Available Jobs'), // Chỉ một tiêu đề
          const SizedBox(height: 16),
          _buildJobsList(vm), // Danh sách chính
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

  // (Các hàm _buildHeader và _buildSearchCard giữ nguyên như trước)
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0).copyWith(bottom: 60),
      decoration: const BoxDecoration(
        color: Color(0xFF008080),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Let's find job",
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSearchField(Icons.search, 'Search job, company'),
          const Divider(height: 20, thickness: 1),
          _buildSearchField(Icons.location_on_outlined, 'Location'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF008080),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Search',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(IconData icon, String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
      ),
    );
  }
  // ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // Bỏ 'See All'
        ],
      ),
    );
  }

  // Bỏ hàm _buildPopularJobsList()

  Widget _buildJobsList(HomeViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(), // Để cuộn theo SingleChildScrollView
        shrinkWrap: true,
        itemCount: vm.jobs.length,
        itemBuilder: (context, index) {
          // Sử dụng SuggestedJobCard cho tất cả item
          return SuggestedJobCard(job: vm.jobs[index]);
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    // (Giữ nguyên code _buildBottomNav như trước)
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF008080),
      unselectedItemColor: Colors.grey.shade500,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border), label: 'Saved'),
        BottomNavigationBarItem(
            icon: Icon(Icons.work_outline), label: 'Applied'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), label: 'Message'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}