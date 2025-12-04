import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../view_models/user/home_view_model.dart';
import '../../../view_models/user/save_job_view_model.dart';
import '../../../widget/user/home/home_header.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key để mở Drawer

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
      key: _scaffoldKey, // Gán Key
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(context, vm),
      drawer: _buildDrawer(context, vm), // ✅ THÊM DRAWER
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

  // ✅ WIDGET DRAWER MỚI
  Widget _buildDrawer(BuildContext context, HomeViewModel vm) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF00C89C)),
            accountName: Text(vm.isRecommendedMode ? "Người dùng" : "Khách"),
            accountEmail: Text(vm.currentEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: const Color(0xFF00C89C)),
            ),
          ),

          // 1. Quét CV
          ListTile(
            leading: const Icon(Icons.document_scanner, color: Colors.blue),
            title: const Text("Quét CV (Scan PDF)"),
            onTap: () {
              Navigator.pop(context); // Đóng drawer
              if (vm.isRecommendedMode) {
                Navigator.pushNamed(context, '/scan_pdf');
              } else {
                _showLoginRequired(context);
              }
            },
          ),

          // 2. Tạo CV Gemini
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: Colors.purple),
            title: const Text("Tạo CV với Gemini AI"),
            onTap: () {
              Navigator.pop(context);
              if (vm.isRecommendedMode) {
                // Điều hướng đến trang Gemini CV (ví dụ: '/cv_gemini' hoặc '/cv_generator')
                // Trong routes của bạn có: '/cv_generator' -> CvTemplateSelectionScreen
                // và '/cv_gemini' -> chưa thấy trong routes nhưng có file 'gemini_cv_screen.dart'
                // Giả sử dùng GeminiCvScreen:
                Navigator.pushNamed(context, '/cv_generator');
              } else {
                _showLoginRequired(context);
              }
            },
          ),

          const Divider(),

          // 3. Cài đặt
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text("Cài đặt"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }

  void _showLoginRequired(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vui lòng đăng nhập để sử dụng tính năng này")),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, HomeViewModel vm) {
    return AppBar(
      backgroundColor: const Color(0xFF00C89C),
      elevation: 0,
      // Thêm nút Menu để mở Drawer
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
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
          IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Đăng xuất',
              onPressed: () async {
                final confirm = await showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Đăng xuất"), content: const Text("Bạn có muốn đăng xuất?"), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Đồng ý", style: TextStyle(color: Colors.red)))]));
                if (confirm == true) await vm.logout();
              }
          ),
      ],
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
              HomeHeader(userName: vm.currentEmail),
              Positioned(
                top: 100, left: 20, right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                  child: _buildFakeSearchBar(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),

          // Banner Slider
          const SizedBox(height: 20),
          _buildBannerSection(),

          const SizedBox(height: 20),

          // ✅ MENU NHANH (SHORTCUTS) - Thêm phần này để truy cập nhanh ngoài Drawer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShortcutItem(Icons.document_scanner, "Scan CV", Colors.blue, () {
                  if (vm.isRecommendedMode) Navigator.pushNamed(context, '/scan_pdf');
                  else _showLoginRequired(context);
                }),
                _buildShortcutItem(Icons.auto_awesome, "AI CV", Colors.purple, () {
                  if (vm.isRecommendedMode) Navigator.pushNamed(context, '/cv_generator');
                  else _showLoginRequired(context);
                }),
                _buildShortcutItem(Icons.settings, "Cài đặt", Colors.orange, () => Navigator.pushNamed(context, '/settings')),
              ],
            ),
          ),
          const SizedBox(height: 20),

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

          // Loading More Indicator
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

  // Widget Shortcut Item (Icon tròn + Text)
  Widget _buildShortcutItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // (Giữ nguyên _buildBannerSection, _buildJobItem, _buildTag, _buildFakeSearchBar, _showFilterScreen)
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
                child: hasLogo ? Image.network(logoUrl, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Icon(Icons.business, color: Colors.grey[400], size: 30)) : Icon(Icons.business, color: Colors.grey[400], size: 30),
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

  Widget _buildFakeSearchBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.0), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Row(children: [Icon(Icons.search, color: const Color(0xFF00C89C)), const SizedBox(width: 12), Text('Tìm kiếm việc làm, công ty...', style: TextStyle(color: Colors.grey[500], fontSize: 15))]),
    );
  }

  void _showFilterScreen(BuildContext context) {
    final vm = context.read<HomeViewModel>();
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => ChangeNotifierProvider.value(value: vm, child: const FilterScreen()));
  }
}