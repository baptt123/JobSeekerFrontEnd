// lib/views/login/user/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../view_models/user/home_view_model.dart';
import '../../../view_models/user/save_job_view_model.dart';
import '../../../widget/user/home/home_header.dart'; // Import file Header vừa sửa ở trên
import 'conversation_list_screen.dart';
import 'filter_screen.dart';
import 'search_screen.dart';
import 'job_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchInitialData();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<HomeViewModel>().loadMoreJobs();
      }
    });

    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        int nextPage = _currentBannerIndex + 1;
        if (nextPage > 2) nextPage = 0;
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
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9F9F9),
      // Bỏ AppBar mặc định đi vì chúng ta đã có HomeHeader đẹp rồi
      // Hoặc nếu muốn giữ nút Menu thì set background trong suốt
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Trong suốt để thấy Header bên dưới
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterScreen(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context, vm),
      body: Stack(
        children: [
          _buildBody(context, vm),
          if (vm.state == HomeState.loading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // ✅ DRAWER: Xử lý logic Đăng nhập / Đăng xuất
  Widget _buildDrawer(BuildContext context, HomeViewModel vm) {
    final user = vm.currentUser;
    final bool isUserLoggedIn = vm.isRecommendedMode; // Hoặc check user != null

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF00C89C)),
            accountName: Text(
              isUserLoggedIn ? (user?.fullName ?? "Người dùng") : "Khách",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(isUserLoggedIn ? (user?.email ?? "") : "Vui lòng đăng nhập"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (isUserLoggedIn && user?.avatarUrl != null)
                  ? NetworkImage(user!.avatarUrl!)
                  : null,
              child: (!isUserLoggedIn || user?.avatarUrl == null)
                  ? const Icon(Icons.person, size: 40, color: Color(0xFF00C89C))
                  : null,
            ),
          ),

          // Menu Items chung
          ListTile(
            leading: const Icon(Icons.document_scanner, color: Colors.blue),
            title: const Text("Quét CV (Scan PDF)"),
            onTap: () {
              Navigator.pop(context);
              if (isUserLoggedIn) {
                Navigator.pushNamed(context, '/scan_pdf');
              } else {
                _showLoginRequired(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: Colors.purple),
            title: const Text("Tạo CV với Gemini AI"),
            onTap: () {
              Navigator.pop(context);
              if (isUserLoggedIn) {
                Navigator.pushNamed(context, '/cv_generator');
              } else {
                _showLoginRequired(context);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text("Cài đặt"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),

          const Spacer(), // Đẩy phần Login/Logout xuống đáy
          const Divider(),

          // ✅ NÚT LOGIN / LOGOUT DỰA TRÊN TRẠNG THÁI
          if (isUserLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Đăng xuất", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                        title: const Text("Đăng xuất"),
                        content: const Text("Bạn có muốn đăng xuất?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Đồng ý", style: TextStyle(color: Colors.red)))
                        ]
                    )
                );
                if (confirm == true) await vm.logout();
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login, color: Color(0xFF00C89C)),
              title: const Text("Đăng nhập", style: TextStyle(color: Color(0xFF00C89C), fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLoginRequired(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Vui lòng đăng nhập để sử dụng tính năng này"),
        action: SnackBarAction(
          label: 'Đăng nhập',
          onPressed: () => Navigator.pushNamed(context, '/login'),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel vm) {
    if (vm.state == HomeState.error && vm.jobs.isEmpty) return Center(child: Text(vm.errorMessage ?? "Lỗi tải dữ liệu"));

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Search
          Stack(
            clipBehavior: Clip.none,
            children: [
              // ✅ Header mới xử lý cả Login/Guest
              HomeHeader(user: vm.currentUser),

              // Search Bar đè lên
              Positioned(
                bottom: 0, // Đặt ở đáy của Header (do padding bottom header lớn)
                left: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                  child: _buildFakeSearchBar(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30), // Khoảng cách sau SearchBar

          // Banner Slider
          _buildBannerSection(),
          const SizedBox(height: 24),

          // Tiêu đề danh sách
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  vm.isRecommendedMode ? 'Gợi ý từ CV của bạn' : 'Việc làm mới nhất',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Danh sách công việc
          if (vm.jobs.isEmpty && vm.state == HomeState.success)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: Text("Chưa có việc làm phù hợp.")),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.jobs.length,
              itemBuilder: (context, index) {
                return _buildJobItem(context, vm, index);
              },
            ),

          // Loading More
          if (vm.state == HomeState.loadingMore)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // --- Các hàm phụ trợ (FakeSearch, Banner, JobItem) giữ nguyên như cũ ---
  Widget _buildFakeSearchBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))
          ]
      ),
      child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF00C89C)),
            const SizedBox(width: 12),
            Text('Tìm kiếm việc làm, công ty...', style: TextStyle(color: Colors.grey[500], fontSize: 14))
          ]
      ),
    );
  }

  Widget _buildBannerSection() {
    return SizedBox(
      height: 160,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _bannerController,
              onPageChanged: (index) => setState(() => _currentBannerIndex = index),
              children: [
                _buildBannerItem(const Color(0xFF4A90E2), "Tuyển dụng IT", "Lương lên đến \$2000", Icons.code),
                _buildBannerItem(const Color(0xFFFF9F43), "Cơ hội Marketing", "Môi trường năng động", Icons.campaign),
                _buildBannerItem(const Color(0xFF5F27CD), "Thiết kế đồ hoạ", "Sáng tạo không giới hạn", Icons.brush),
              ],
            ),
          ),
          const SizedBox(height: 10),
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
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
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

  Widget _buildJobItem(BuildContext context, HomeViewModel vm, int index) {
    final job = vm.jobs[index];
    final logoUrl = job.company?.logoUrl;
    final bool hasLogo = logoUrl != null && logoUrl.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black12,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailScreen(jobTitle: job.title)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                padding: const EdgeInsets.all(4),
                child: hasLogo
                    ? Image.network(logoUrl, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Icon(Icons.business, color: Colors.grey[400], size: 30))
                    : Icon(Icons.business, color: Colors.grey[400], size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(job.company?.name ?? 'Công ty ẩn danh', style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (job.location != null) ...[_buildTag(Icons.location_on_outlined, job.location!), const SizedBox(width: 8)],
                        if (job.jobType != null) _buildTag(Icons.access_time, job.jobType!),
                      ],
                    )
                  ],
                ),
              ),
              IconButton(
                icon: Icon(vm.isJobSaved(job.jobId) ? Icons.bookmark : Icons.bookmark_border, color: vm.isJobSaved(job.jobId) ? const Color(0xFF00C89C) : Colors.grey[400]),
                onPressed: () { vm.toggleSaveJob(job, context, context.read<SavedJobsViewModel>()); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(child: Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 11), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  void _showFilterScreen(BuildContext context) {
    final vm = context.read<HomeViewModel>();
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => ChangeNotifierProvider.value(value: vm, child: const FilterScreen()));
  }
}