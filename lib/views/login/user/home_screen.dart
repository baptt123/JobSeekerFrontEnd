import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Dùng cho auto slide banner

import '../../../view_models/user/home_view_model.dart';
import '../../../widget/user/home/home_header.dart';
import '../../../widget/user/home/job_list.dart';
import 'conversation_list_screen.dart';
import 'filter_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller để bắt sự kiện cuộn
  final ScrollController _scrollController = ScrollController();

  // Controller cho Banner
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();

    // 1. Fetch data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchInitialData();
    });

    // 2. Lắng nghe sự kiện cuộn để Load More
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        // Khi cuộn gần đến đáy (còn 200px), gọi load more
        context.read<HomeViewModel>().loadMoreJobs();
      }
    });

    // 3. Tự động chạy Banner
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        int nextPage = _currentBannerIndex + 1;
        if (nextPage > 2) nextPage = 0; // Giả sử có 3 banner
        _bannerController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(context, vm),
      body: Stack(
        children: [
          // Truyền controller vào body để SingleChildScrollView sử dụng
          _buildBody(context, vm),

          // Loading toàn màn hình (chỉ khi mới vào app hoặc refresh)
          if (vm.state == HomeState.loading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // ... (Giữ nguyên _buildAppBar) ...
  PreferredSizeWidget _buildAppBar(BuildContext context, HomeViewModel vm) {
    // Copy code AppBar từ câu trả lời trước
    return AppBar(
      backgroundColor: const Color(0xFF00C89C),
      elevation: 0,
      title: const Text('Job Seeker',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(icon: const Icon(Icons.filter_list), onPressed: () => _showFilterScreen(context)),
        if (vm.isRecommendedMode)
          IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConversationListScreen()))),
        if (!vm.isRecommendedMode)
          Padding(padding: const EdgeInsets.only(right: 8.0), child: TextButton.icon(onPressed: () => Navigator.pushNamed(context, '/login'), icon: const Icon(Icons.login, color: Colors.white), label: const Text('Đăng nhập', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: TextButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))))),
        if (vm.isRecommendedMode)
          IconButton(icon: const Icon(Icons.logout), onPressed: () async { await vm.logout(); }),
      ],
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel vm) {
    if (vm.state == HomeState.error && vm.jobs.isEmpty) return Center(child: Text(vm.errorMessage ?? "Lỗi"));

    return SingleChildScrollView( // ✅ Dùng SingleChildScrollView bao ngoài để cuộn cả trang
      controller: _scrollController, // ✅ Gắn controller vào đây
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header & Search
          Stack(
            clipBehavior: Clip.none,
            children: [
              HomeHeader(userName: vm.currentEmail),
              Positioned(
                top: 100,
                left: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                  child: _buildFakeSearchBar(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50), // Tăng khoảng cách vì search bar nằm đè lên

          // 2. ✅ KHUNG BANNER MỚI
          const SizedBox(height: 20),
          _buildBannerSection(),

          const SizedBox(height: 20),

          // 3. Tiêu đề danh sách
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  vm.isRecommendedMode ? 'Gợi ý từ CV của bạn' : 'Việc làm mới nhất',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Có thể thêm nút "Xem tất cả" nếu muốn
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Danh sách công việc
          // Lưu ý: Vì nằm trong SingleChildScrollView, ListView cần shrinkWrap: true và physics: NeverScrollableScrollPhysics
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            shrinkWrap: true, // ✅ Quan trọng
            physics: const NeverScrollableScrollPhysics(), // ✅ Quan trọng
            itemCount: vm.jobs.length,
            itemBuilder: (context, index) {
              // Sử dụng lại logic hiển thị JobCard/ListTile từ code cũ của bạn
              // Ở đây tôi gọi widget JobCard (hoặc bạn dùng code ListTile cũ)
              // return JobCard(job: vm.jobs[index]);
              // Hoặc copy đoạn code ListTile trong JobsList cũ bỏ vào đây
              return _buildJobItem(context, vm, index);
            },
          ),

          // 5. Loading Indicator ở cuối trang (Load More)
          if (vm.state == HomeState.loadingMore)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            ),

          const SizedBox(height: 80), // Padding bottom để không bị che bởi bottom nav
        ],
      ),
    );
  }

  // ✅ Widget Banner Slider
  Widget _buildBannerSection() {
    return SizedBox(
      height: 160, // Chiều cao banner
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _bannerController,
              onPageChanged: (index) {
                setState(() => _currentBannerIndex = index);
              },
              children: [
                _buildBannerItem(Colors.blueAccent, "Tuyển dụng IT", "Lương lên đến \$2000", Icons.code),
                _buildBannerItem(Colors.orangeAccent, "Cơ hội Marketing", "Môi trường năng động", Icons.campaign),
                _buildBannerItem(Colors.purpleAccent, "Thiết kế đồ hoạ", "Sáng tạo không giới hạn", Icons.brush),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Dấu chấm chỉ số trang
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index ? const Color(0xFF00C89C) : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            )),
          )
        ],
      ),
    );
  }

  Widget _buildBannerItem(Color color, String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 60),
          )
        ],
      ),
    );
  }

  // Hàm render item job (Tách từ JobsList cũ)
  Widget _buildJobItem(BuildContext context, HomeViewModel vm, int index) {
    final job = vm.jobs[index];
    // Copy logic hiển thị từ JobsList vào đây để đồng bộ
    // Ví dụ đơn giản:
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0, // Flat style như ảnh
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(10)
          ),
          child: Icon(Icons.business, color: Colors.grey[400]), // Thay bằng Logo nếu có
        ),
        title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(job.company?.name ?? 'Unknown Company'),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTag(job.location ?? 'Remote'),
                const SizedBox(width: 8),
                _buildTag(job.jobType ?? 'Fulltime'),
              ],
            )
          ],
        ),
        // trailing: Icon(Icons.bookmark_border), // Xử lý save job sau
        onTap: () {
          // Điều hướng sang Detail
          // Navigator.push...
        },
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
    );
  }

  Widget _buildFakeSearchBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(children: [Icon(Icons.search, color: Colors.grey[600]), const SizedBox(width: 12), Text('Tìm kiếm việc làm...', style: TextStyle(color: Colors.grey[700], fontSize: 16))]),
    );
  }

  // (Hàm _showFilterScreen giữ nguyên)
  void _showFilterScreen(BuildContext context) {
    final vm = context.read<HomeViewModel>();
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => ChangeNotifierProvider.value(value: vm, child: const FilterScreen()));
  }
}