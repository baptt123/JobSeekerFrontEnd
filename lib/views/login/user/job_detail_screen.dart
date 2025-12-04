import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/job-entity.dart';
import '../../../view_models/user/job_detail_view_model.dart';

class JobDetailScreen extends StatelessWidget {
  final String jobTitle;
  const JobDetailScreen({super.key, required this.jobTitle});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobDetailViewModel(),
      child: _JobDetailViewBody(jobTitle: jobTitle),
    );
  }
}

class _JobDetailViewBody extends StatefulWidget {
  final String jobTitle;
  const _JobDetailViewBody({required this.jobTitle});

  @override
  State<_JobDetailViewBody> createState() => _JobDetailViewBodyState();
}

class _JobDetailViewBodyState extends State<_JobDetailViewBody> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobDetailViewModel>(context, listen: false).fetchJobDetail(widget.jobTitle);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isExpired(DateTime? deadline) {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline);
  }

  String _getDeadlineText(DateTime? deadline) {
    if (deadline == null) return "Không thời hạn";
    final diff = deadline.difference(DateTime.now()).inDays;
    if (diff < 0) return "Đã hết hạn";
    if (diff == 0) return "Hết hạn hôm nay";
    return "$diff ngày nữa";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Consumer<JobDetailViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF00C89C)));
          if (vm.hasError) return Center(child: Text("Lỗi: ${vm.errorMessage}"));
          if (vm.job == null) return const Center(child: Text("Không tìm thấy công việc"));

          return Column(
            children: [
              Expanded(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildLogoAndTitle(vm.job!),
                            const SizedBox(height: 20),
                            _buildInfoTags(vm.job!),
                            const SizedBox(height: 24),
                            _buildTabBar(),
                          ],
                        ),
                      ),
                    )
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDescriptionTab(vm.job!),
                      _buildCompanyTab(vm.job!),
                      const Center(child: Text("Chưa có đánh giá nào")),
                    ],
                  ),
                ),
              ),
              _buildBottomAction(context, vm),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: const Text("Chi tiết công việc", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      actions: [
        Consumer<JobDetailViewModel>(
          builder: (context, vm, _) {
            return IconButton(
              icon: Icon(
                vm.isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: vm.isSaved ? const Color(0xFF00C89C) : Colors.black54,
                size: 26,
              ),
              onPressed: () => vm.toggleSaveJob(context),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.black54),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ✅ CẬP NHẬT 1: Thay thế Icon bằng ảnh Logo App khi lỗi/không có ảnh
  Widget _buildLogoAndTitle(JobEntity job) {
    final logoUrl = job.company?.logoUrl;
    final hasLogo = logoUrl != null && logoUrl.isNotEmpty;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: hasLogo
              ? Image.network(
            logoUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Nếu link ảnh lỗi (404), hiển thị logo mặc định của App
              return Image.asset('assets/icon/logo.png', fit: BoxFit.contain);
            },
          )
          // Nếu không có link ảnh, hiển thị logo mặc định của App
              : Image.asset('assets/icon/logo.png', fit: BoxFit.contain),
        ),
        const SizedBox(height: 16),
        Text(
          job.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3),
        ),
        const SizedBox(height: 8),
        Text(
          job.company?.name ?? "Công ty ẩn danh",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildInfoTags(JobEntity job) {
    String salaryText = "Thương lượng";
    if (job.salaryMin != null && job.salaryMax != null) {
      double minM = job.salaryMin! / 1000000;
      double maxM = job.salaryMax! / 1000000;
      salaryText = "${minM.toStringAsFixed(0)} - ${maxM.toStringAsFixed(0)} Triệu";
    }

    final isExpired = _isExpired(job.deadline);
    final deadlineText = _getDeadlineText(job.deadline);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _buildTagChip(Icons.location_on_outlined, job.location ?? "Remote", Colors.blue),
        _buildTagChip(Icons.access_time, job.jobType ?? "Full-time", Colors.orange),
        _buildTagChip(Icons.monetization_on_outlined, salaryText, const Color(0xFF00C89C)),
        _buildTagChip(Icons.timer_outlined, deadlineText, isExpired ? Colors.red : Colors.purple),
      ],
    );
  }

  Widget _buildTagChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  // ✅ CẬP NHẬT 2: Tab Indicator full width
  Widget _buildTabBar() {
    return Container(
      height: 45,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        // 🔥 QUAN TRỌNG: Để highlight to bằng tab
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        labelColor: Colors.black87,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [
          Tab(text: "Mô tả"),
          Tab(text: "Công ty"),
          Tab(text: "Review"),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab(JobEntity job) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Mô tả công việc", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(job.description ?? "Chưa có mô tả chi tiết.", style: const TextStyle(color: Colors.black54, height: 1.6)),
          const SizedBox(height: 24),
          const Text("Yêu cầu ứng viên", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (job.requirements != null)
            ...job.requirements!.split('\n').map((req) {
              if (req.trim().isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 6.0), child: Icon(Icons.circle, size: 6, color: Color(0xFF00C89C))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(req.trim(), style: const TextStyle(color: Colors.black54, height: 1.5))),
                  ],
                ),
              );
            }).toList()
          else
            const Text("Không có yêu cầu cụ thể.", style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCompanyTab(JobEntity job) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Giới thiệu công ty", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(job.company?.description ?? "Đang cập nhật...", style: const TextStyle(color: Colors.black54, height: 1.6)),
          const SizedBox(height: 24),
          _buildCompanyInfoRow(Icons.language, "Website", job.company?.website ?? "N/A"),
          const SizedBox(height: 16),
          _buildCompanyInfoRow(Icons.location_on, "Địa chỉ", job.company?.address ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF00C89C), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context, JobDetailViewModel vm) {
    final isExpired = _isExpired(vm.job!.deadline);
    final isApplied = vm.isApplied;
    final isSaving = vm.isApplying;

    String btnText = "Ứng tuyển ngay";
    Color btnColor = const Color(0xFF00C89C);
    VoidCallback? onPressed = () => vm.applyForJob(context);

    if (isExpired) {
      btnText = "Đã hết hạn";
      btnColor = Colors.grey;
      onPressed = null;
    } else if (isApplied) {
      btnText = "Đã ứng tuyển";
      btnColor = Colors.blueAccent;
      onPressed = null;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isSaving ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            disabledBackgroundColor: btnColor.withOpacity(0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isSaving
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(btnText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}