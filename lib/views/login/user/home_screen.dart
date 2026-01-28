import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/view_models/user/login_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../view_models/user/home_view_model.dart';
import '../../../view_models/user/save_job_view_model.dart';
import '../../../view_models/user/user_profile_view_model.dart';
import '../../../widget/user/home/home_header.dart';
import '../../../models/job-entity.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchInitialData();
      context.read<ProfileViewModel>().fetchUserProfile();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<HomeViewModel>().loadMoreJobs();
      }
    });
  }

  void _startBannerTimer(int totalBanners) {
    _bannerTimer?.cancel();
    if (totalBanners <= 1) return;

    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerController.hasClients) {
        int nextPage = _currentBannerIndex + 1;
        if (nextPage >= totalBanners) nextPage = 0;
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
    final homeVM = context.watch<HomeViewModel>();
    final profileVM = context.watch<ProfileViewModel>();
    final currentUser = profileVM.user ?? homeVM.currentUser;

    if (homeVM.randomJobs.isNotEmpty && (_bannerTimer == null || !_bannerTimer!.isActive)) {
      _startBannerTimer(homeVM.randomJobs.length);
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context, currentUser),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => homeVM.refreshJobs(),
              color: kPrimaryColor,
              backgroundColor: Theme.of(context).cardTheme.color,
              edgeOffset: 0,
              child: _buildBody(context, homeVM, currentUser),
            ),

            if (homeVM.state == HomeState.loading && homeVM.jobs.isEmpty)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel vm, dynamic user) {
    if (vm.state == HomeState.error && vm.jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(vm.errorMessage ?? "Lỗi tải dữ liệu", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.fetchInitialData(),
              child: const Text("Tải lại trang"),
            )
          ],
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomNavBar(),

          Stack(
            clipBehavior: Clip.none,
            children: [
              HomeHeader(user: user),
              Positioned(
                bottom: 0,
                left: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                  child: _buildFakeSearchBar(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          _buildDynamicBannerSection(vm.randomJobs),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          vm.isRecommendedMode ? 'Gợi ý cho bạn ' : 'Việc làm mới nhất',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (vm.isRecommendedMode)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.purple.withOpacity(0.3))
                            ),
                            // child: const Text("AI Picked", style: TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                    if (vm.isRecommendedMode)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "Dựa trên các công việc bạn đã lưu",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

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
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.jobs.length,
              itemBuilder: (context, index) {
                return _buildJobItem(context, vm, index);
              },
            ),

          if (vm.state == HomeState.loadingMore && !vm.isRecommendedMode)
            const Padding(padding: EdgeInsets.all(20.0), child: Center(child: CircularProgressIndicator(color: kPrimaryColor))),

          if (vm.isRecommendedMode && vm.jobs.isNotEmpty)
            const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: Text("Hết danh sách gợi ý", style: TextStyle(color: Colors.grey, fontSize: 12)))
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCustomNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: kPrimaryColor, size: 28),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const Text(
            "TechConnect",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimaryColor),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: kPrimaryColor, size: 28),
            onPressed: () => _showFilterScreen(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicBannerSection(List<JobEntity> jobs) {
    if (jobs.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _bannerController,
              onPageChanged: (index) => setState(() => _currentBannerIndex = index),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                return _buildJobBannerItem(jobs[index]);
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(jobs.length, (index) => AnimatedContainer(
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

  Widget _buildJobBannerItem(JobEntity job) {
    final List<List<Color>> gradients = [
      [const Color(0xFF6C63FF), const Color(0xFF8B5CF6)],
      [const Color(0xFFFA709A), const Color(0xFFFEE140)],
      [const Color(0xFF00C6FB), const Color(0xFF005BEA)],
      [const Color(0xFF11998e), const Color(0xFF38ef7d)],
      [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
    ];
    final gradient = gradients[(job.jobId) % gradients.length];

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailScreen(jobTitle: job.title))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: gradient.last.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))]
            ),
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
                            Text(job.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(job.company?.name ?? "Công ty nổi bật", style: const TextStyle(color: Colors.white70, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Container(
                        width: 50, height: 50,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              job.company?.logoUrl ?? '',
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, error, stack) => const Icon(Icons.business, color: kPrimaryColor),
                            )
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobItem(BuildContext context, HomeViewModel vm, int index) {
    final job = vm.jobs[index];
    final logoUrl = job.company?.logoUrl;
    final bool hasValidLogo = logoUrl != null && logoUrl.isNotEmpty && logoUrl.startsWith('http');

    // [UPDATED] Hàm format tiền tệ VNĐ (ví dụ: 10.000.000)
    String _formatCurrency(double amount) {
      return amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    }

    // [UPDATED] Logic hiển thị chuỗi lương
    String salaryText;
    if (job.salaryMin != null && job.salaryMax != null) {
      salaryText = "${_formatCurrency(job.salaryMin!)} - ${_formatCurrency(job.salaryMax!)} VNĐ";
    } else if (job.salaryMin != null) {
      salaryText = "Từ ${_formatCurrency(job.salaryMin!)} VNĐ";
    } else {
      salaryText = "Thỏa thuận";
    }

    final bool isSaved = vm.isJobSaved(job.jobId);

    final cardColor = Theme.of(context).cardTheme.color;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 2, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailScreen(jobTitle: job.title))),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200)
                  ),
                  padding: const EdgeInsets.all(4),
                  child: hasValidLogo
                      ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.business_outlined, color: Colors.grey)),
                      )
                  )
                      : Center(child: Text(job.company?.name?[0] ?? "C", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: kPrimaryColor))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.3, color: textColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(job.company?.name ?? 'Công ty ẩn danh', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 6,
                        children: [
                          if (job.location != null) _buildTag(context, Icons.location_on_outlined, job.location!),

                          // [UPDATED] Hiển thị tag lương với định dạng mới
                          _buildTag(context, Icons.attach_money, salaryText, color: Colors.green.shade700, bgColor: Colors.green.withOpacity(0.1)),

                          if (job.jobType != null) _buildTag(context, Icons.work_outline, job.jobType!, color: Colors.blue.shade700, bgColor: Colors.blue.withOpacity(0.1)),
                        ],
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => vm.toggleSaveJob(job, context, context.read<SavedJobsViewModel>()),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8, top: 0),
                    child: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border_rounded, color: isSaved ? kPrimaryColor : Colors.grey[400], size: 26),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, IconData icon, String text, {Color? color, Color? bgColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBgColor = bgColor ?? (isDark ? Colors.grey[800] : Colors.grey[100]);
    final effectiveTextColor = color ?? (isDark ? Colors.grey[300] : Colors.grey[700]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: effectiveBgColor, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: effectiveTextColor),
          const SizedBox(width: 4),
          Flexible(child: Text(text, style: TextStyle(color: effectiveTextColor, fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, maxLines: 1)),
        ],
      ),
    );
  }

  void _showFilterScreen(BuildContext context) {
    final vm = context.read<HomeViewModel>();
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (_) => ChangeNotifierProvider.value(value: vm, child: const FilterScreen()));
  }

  void _showLoginRequired(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Vui lòng đăng nhập"), action: SnackBarAction(label: 'Đăng nhập', onPressed: () => Navigator.pushNamed(context, '/login'))));
  }

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
            leading: const Icon(Icons.auto_awesome, color: Colors.deepPurpleAccent),
            title: const Text("Tạo CV với Gemini AI"),
            onTap: () { Navigator.pop(context); isUserLoggedIn ? Navigator.pushNamed(context, '/cv_generator') : _showLoginRequired(context); },
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.orange),
            title: const Text("Quản lý CV và Scan CV"),
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
                if (confirm == true) await context.read<LoginViewModel>().logout(context);
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

  Widget _buildFakeSearchBar(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]
      ),
      child: Row(children: [const Icon(Icons.search, color: kPrimaryColor), const SizedBox(width: 12), const Expanded(child: Text('Tìm kiếm việc làm, công ty...', style: TextStyle(color: Colors.grey, fontSize: 14), overflow: TextOverflow.ellipsis))]),
    );
  }
}