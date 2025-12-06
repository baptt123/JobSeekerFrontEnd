// lib/views/login/user/job_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/job-entity.dart';
import '../../../view_models/user/job_detail_view_model.dart';
// import màn hình chat...

const Color kPrimaryColor = Color(0xFF6C63FF);

class JobDetailScreen extends StatefulWidget {
  final String jobTitle;

  const JobDetailScreen({super.key, required this.jobTitle});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobDetailViewModel()..fetchJobDetail(widget.jobTitle),
      child: Consumer<JobDetailViewModel>(
        builder: (context, vm, _) {
          final job = vm.job;

          if (vm.isLoading) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
            );
          }

          if (job == null) {
            return _buildErrorState(context);
          }

          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 240.0, // 🔥 Tăng chiều cao Header để chứa ảnh to hơn
                    floating: false,
                    pinned: true,
                    backgroundColor: kPrimaryColor,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeaderContent(job),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: kPrimaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: kPrimaryColor,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(text: "Thông tin"),
                          Tab(text: "Công ty"),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildJobInfo(job),
                  _buildCompanyInfo(job),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomAction(context, vm, job),
          );
        },
      ),
    );
  }

  // 🔥 FIX 1 & 2: Xử lý lỗi ảnh và Tăng kích thước
  Widget _buildHeaderContent(JobEntity job) {
    // Logic kiểm tra link ảnh hợp lệ
    String? logoUrl = job.company?.logoUrl;
    bool isValidUrl = logoUrl != null && logoUrl.isNotEmpty && logoUrl.toLowerCase().startsWith('http');

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [kPrimaryColor, Color(0xFF5F27CD)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // 🔥 Tăng kích thước từ 80 lên 110
              width: 110,
              height: 110,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), // Bo góc mềm mại hơn
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                  ]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isValidUrl
                    ? Image.network(
                  logoUrl,
                  fit: BoxFit.contain,
                  // Xử lý nếu link http bị chết (404)
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.business, size: 50, color: Colors.grey);
                  },
                )
                    : const Icon(Icons.business, size: 50, color: Colors.grey), // Hiển thị icon nếu url không hợp lệ
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                job.company?.name ?? "Công ty ẩn danh",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildJobInfo(JobEntity job) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(job.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text("\$${job.salaryMin} - \$${job.salaryMax}", style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded( // Thêm Expanded để tránh lỗi tràn màn hình nếu địa chỉ dài
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Flexible(child: Text(job.location ?? "Remote", style: const TextStyle(fontSize: 14, color: Colors.black54), overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Mô tả công việc", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(job.description ?? '', style: const TextStyle(height: 1.6, fontSize: 15)),
          const SizedBox(height: 24),
          const Text("Yêu cầu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(job.requirements ?? '', style: const TextStyle(height: 1.6, fontSize: 15)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo(JobEntity job) {
    final company = job.company;
    if (company == null) return const Center(child: Text("Không có thông tin công ty"));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Thông tin doanh nghiệp", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildCompanyDetailRow(Icons.business, "Tên công ty", company.name ?? "N/A"),
          const SizedBox(height: 12),
          _buildCompanyDetailRow(Icons.map, "Địa chỉ", company.address ?? "Chưa cập nhật"),
          const SizedBox(height: 12),
          _buildCompanyDetailRow(Icons.language, "Website", company.website ?? "Chưa cập nhật"),
          const Divider(height: 40),
          const Text("Giới thiệu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            company.description ?? "Chưa có mô tả chi tiết.",
            style: const TextStyle(height: 1.5, fontSize: 15, color: Colors.black87),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCompanyDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: kPrimaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context, JobDetailViewModel vm, JobEntity job) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                onPressed: () {
                  // Uncomment và sửa lại cho đúng với navigation của bạn
                  /*
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        partnerId: job.company?.id,
                        partnerName: job.company?.name,
                        partnerAvatar: job.company?.logoUrl,
                      ),
                    ),
                  );
                  */
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Chuyển sang màn hình chat...")),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kPrimaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                label: const Text("Chat ngay", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: vm.isApplied ? null : () => vm.applyForJob(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(vm.isApplied ? "Đã ứng tuyển" : "Ứng tuyển", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text("Không tìm thấy công việc:\n\"${widget.jobTitle}\"", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              child: const Text("Quay lại", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}