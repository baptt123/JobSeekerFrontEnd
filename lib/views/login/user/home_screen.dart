// lib/views/login/user/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../view_models/user/home_view_model.dart';
import '../../../view_models/user/save_job_view_model.dart';
// Import ProfileViewModel để lắng nghe thay đổi ảnh đại diện
import '../../../view_models/user/user_profile_view_model.dart';
import '../../../widget/user/home/home_header.dart';
import 'filter_screen.dart';
import 'search_screen.dart';
import 'job_detail_screen.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

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

  final int _totalBanners = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. Fetch dữ liệu Job cho Home
      context.read<HomeViewModel>().fetchInitialData();

      // 2. Fetch Profile để đảm bảo có ảnh mới nhất ngay khi mở app
      context.read<ProfileViewModel>().fetchUserProfile();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<HomeViewModel>().loadMoreJobs();
      }
    });

    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerController.hasClients) {
        int nextPage = _currentBannerIndex + 1;
        if (nextPage >= _totalBanners) nextPage = 0;
        _bannerController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn
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
    // 🔥 Lắng nghe HomeViewModel: Bất cứ khi nào danh sách saved thay đổi (dù ở Home hay Detail), Widget này sẽ rebuild
    final homeVM = context.watch<HomeViewModel>();

    // Lắng nghe ProfileViewModel
    final profileVM = context.watch<ProfileViewModel>();
    final currentUser = profileVM.user ?? homeVM.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9F9F9),
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "TechConnect",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
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

      drawer: _buildDrawer(context, currentUser),

      body: Stack(
        children: [
          _buildBody(context, homeVM, currentUser),

          if (homeVM.state == HomeState.loading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
            ),
        ],
      ),
    );
  }

// Widget hiển thị phần thân màn hình chính
  Widget _buildBody(BuildContext context, HomeViewModel vm, dynamic user) {
    // 1. Xử lý trường hợp lỗi và không có dữ liệu
    if (vm.state == HomeState.error && vm.jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(vm.errorMessage ?? "Lỗi tải dữ liệu", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.fetchInitialData(),
              child: const Text("Thử lại"),
            )
          ],
        ),
      );
    }

    // 2. Nội dung chính (Scrollable)
    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. Header + Thanh tìm kiếm (Stack chồng lên nhau)
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Header chứa Avatar, Tên, Notification
              HomeHeader(user: user),

              // Thanh tìm kiếm giả (Fake Search Bar) nằm đè lên Header
              Positioned(
                bottom: 0,
                left: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen())
                  ),
                  child: _buildFakeSearchBar(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // B. Banner quảng cáo / Nổi bật
          _buildBannerSection(),

          const SizedBox(height: 24),

          // C. Tiêu đề danh sách việc làm (Logic hiển thị theo chế độ Gợi ý)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề chính
                    Text(
                      vm.isRecommendedMode
                          ? 'Việc làm phù hợp với bạn ✨' // Chế độ gợi ý từ CV
                          : 'Việc làm mới nhất',          // Chế độ mặc định
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),

                    // Dòng phụ giải thích (chỉ hiện khi đang gợi ý)
                    if (vm.isRecommendedMode)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "Dựa trên kỹ năng trong CV chính của bạn",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),

                // Nút "Xem tất cả" (Tùy chọn)
                /*
                TextButton(
                  onPressed: () { ... },
                  child: const Text("Xem tất cả", style: TextStyle(color: kPrimaryColor)),
                )
                */
              ],
            ),
          ),

          const SizedBox(height: 16),

          // D. Danh sách công việc (ListView)
          if (vm.jobs.isEmpty && vm.state == HomeState.success)
            const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.work_off_outlined, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("Chưa tìm thấy công việc phù hợp.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
            )
          else
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              shrinkWrap: true, // Quan trọng để nằm trong SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Tắt scroll riêng của ListView
              itemCount: vm.jobs.length,
              itemBuilder: (context, index) {
                return _buildJobItem(context, vm, index);
              },
            ),

          // E. Loading Indicator khi tải thêm (Load More)
          if (vm.state == HomeState.loadingMore)
            const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator(color: kPrimaryColor))
            ),

          // Khoảng trống dưới cùng để không bị che bởi BottomNavigationBar
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Widget hiển thị từng Job Item
  Widget _buildJobItem(BuildContext context, HomeViewModel vm, int index) {
    final job = vm.jobs[index];
    final logoUrl = job.company?.logoUrl;
    final bool hasValidLogo = logoUrl != null && logoUrl.isNotEmpty && logoUrl.startsWith('http');
    final String salaryText = job.salaryMin != null && job.salaryMax != null
        ? "\$${(job.salaryMin!/1000).toInt()}k - \$${(job.salaryMax!/1000).toInt()}k"
        : "\$${(job.salaryMin ?? 0)/1000}k+";

    // Kiểm tra trạng thái đã lưu
    final bool isSaved = vm.isJobSaved(job.jobId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black12,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Chuyển sang màn hình chi tiết
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JobDetailScreen(jobTitle: job.title))
          );
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
                child: hasValidLogo
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
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        if (job.location != null) _buildConstrainedTag(Icons.location_on_outlined, job.location!),
                        _buildConstrainedTag(Icons.attach_money, salaryText, color: Colors.green),
                        if (job.jobType != null) _buildConstrainedTag(Icons.access_time, job.jobType!),
                      ],
                    )
                  ],
                ),
              ),

              // 🔥 NÚT SAVE JOB - ĐIỀU CHỈNH MÀU ĐỎ 🔥
              IconButton(
                icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    // ✅ Nếu đã lưu -> Màu Đỏ (Colors.red), Ngược lại -> Màu xám
                    color: isSaved ? Colors.red : Colors.grey[400]
                ),
                onPressed: () {
                  // Gọi hàm toggleSaveJob trong ViewModel (Hàm này đã xử lý update UI ngay lập tức)
                  vm.toggleSaveJob(job, context, context.read<SavedJobsViewModel>());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Các Widget phụ (Giữ nguyên) ---
  Widget _buildDrawer(BuildContext context, dynamic user) {
    final bool isUserLoggedIn = user != null;
    final String? avatarUrl = user?.avatarUrl;
    final bool hasValidAvatar = avatarUrl != null && avatarUrl.isNotEmpty && avatarUrl.startsWith('http');

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: kPrimaryColor),
            accountName: Text(isUserLoggedIn ? (user.fullName ?? "Người dùng") : "Khách", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(isUserLoggedIn ? (user.email ?? "") : "Vui lòng đăng nhập"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (isUserLoggedIn && hasValidAvatar) ? NetworkImage(avatarUrl) : null,
              child: (!isUserLoggedIn || !hasValidAvatar) ? const Icon(Icons.person, size: 40, color: kPrimaryColor) : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.document_scanner, color: Colors.blueAccent),
            title: const Text("Quét CV (Scan PDF)"),
            onTap: () { Navigator.pop(context); isUserLoggedIn ? Navigator.pushNamed(context, '/scan_pdf') : _showLoginRequired(context); },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome, color: Colors.deepPurpleAccent),
            title: const Text("Tạo CV với Gemini AI"),
            onTap: () { Navigator.pop(context); isUserLoggedIn ? Navigator.pushNamed(context, '/cv_generator') : _showLoginRequired(context); },
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.orange),
            title: const Text("Quản lý CV"),
            onTap: () { Navigator.pop(context); isUserLoggedIn ? Navigator.pushNamed(context, '/manage_cv') : _showLoginRequired(context); },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text("Cài đặt"),
            onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/settings'); },
          ),
          const Spacer(),
          const Divider(),
          if (isUserLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Đăng xuất", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text("Đăng xuất"), content: const Text("Bạn có muốn đăng xuất?"), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Đồng ý", style: TextStyle(color: Colors.red)))]));
                if (confirm == true) await context.read<ProfileViewModel>().logout(context);
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login, color: kPrimaryColor),
              title: const Text("Đăng nhập", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
              onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/login'); },
            ),
        ],
      ),
    );
  }

  Widget _buildFakeSearchBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.0), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Row(children: [const Icon(Icons.search, color: kPrimaryColor), const SizedBox(width: 12), const Expanded(child: Text('Tìm kiếm việc làm, công ty...', style: TextStyle(color: Colors.grey, fontSize: 14), overflow: TextOverflow.ellipsis))]),
    );
  }

  Widget _buildConstrainedTag(IconData icon, String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: (color ?? Colors.grey).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 120),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color ?? Colors.grey[600]),
            const SizedBox(width: 4),
            Flexible(child: Text(text, style: TextStyle(color: color ?? Colors.grey[700], fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return SizedBox(
      height: 180,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _bannerController,
              onPageChanged: (index) => setState(() => _currentBannerIndex = index),
              children: [
                _buildFancyBannerItem([const Color(0xFF6C63FF), const Color(0xFF8B5CF6)], "Tuyển dụng IT", "Lương lên đến \$2000", Icons.code),
                _buildFancyBannerItem([const Color(0xFFFA709A), const Color(0xFFFEE140)], "Marketing 4.0", "Môi trường năng động", Icons.campaign),
                _buildFancyBannerItem([const Color(0xFF00C6FB), const Color(0xFF005BEA)], "Thiết kế UI/UX", "Sáng tạo không giới hạn", Icons.brush),
                _buildFancyBannerItem([const Color(0xFF11998e), const Color(0xFF38ef7d)], "Data Scientist", "Khai phá dữ liệu lớn", Icons.analytics),
                _buildFancyBannerItem([const Color(0xFFFF416C), const Color(0xFFFF4B2B)], "Quản trị nhân sự", "Xây dựng đội ngũ", Icons.people_alt),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalBanners, (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(color: _currentBannerIndex == index ? kPrimaryColor : Colors.grey[300], borderRadius: BorderRadius.circular(4)),
            )),
          )
        ],
      ),
    );
  }

  Widget _buildFancyBannerItem(List<Color> colors, String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: colors.last.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))]),
          child: Stack(
            children: [
              Positioned(top: -20, right: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle))),
              Positioned(bottom: -40, left: -10, child: Container(width: 140, height: 140, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle))),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Text("HOT JOB", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                          const SizedBox(height: 8),
                          Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: Colors.white, size: 40))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterScreen(BuildContext context) {
    final vm = context.read<HomeViewModel>();
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => ChangeNotifierProvider.value(value: vm, child: const FilterScreen()));
  }

  void _showLoginRequired(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Vui lòng đăng nhập để sử dụng tính năng này"), action: SnackBarAction(label: 'Đăng nhập', onPressed: () => Navigator.pushNamed(context, '/login'))));
  }
}