import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/job-entity.dart';
import '../../../view_models/user/job_detail_view_model.dart';
import 'company_detail_screen.dart';
import '../../../widget/user/job/comment_section.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class JobDetailScreen extends StatefulWidget {
  final String jobTitle; // Hoặc jobId (String/int) tùy route
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToCompany(BuildContext context, JobEntity job) {
    final companyId = job.company?.companyId;
    final companyName = job.company?.name ?? "Company";
    if (companyId != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyDetailScreen(companyId: companyId, companyName: companyName)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chưa có thông tin công ty")));
    }
  }

  void _showApplyBottomSheet(BuildContext parentContext, JobDetailViewModel vm) {
    vm.fetchMyCvs(); // Load CV mới nhất
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ChangeNotifierProvider.value(
          value: vm,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: const ApplyJobForm(),
          ),
        );
      },
    );
  }

  // [UPDATED] Dialog xác nhận hủy ứng tuyển sử dụng ViewModel để cập nhật State
  void _showCancelConfirmation(BuildContext context, JobDetailViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận hủy"),
        content: const Text("Bạn có chắc chắn muốn hủy ứng tuyển công việc này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Không", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Đóng dialog trước

              // Gọi ViewModel để hủy và update state
              final success = await vm.cancelApplication(context);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã hủy ứng tuyển thành công")),
                );
                // Lúc này vm.isApplied đã là false -> UI tự đổi nút
              }
            },
            child: const Text("Có, hủy ngay", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobDetailViewModel()..fetchJobDetail(widget.jobTitle),
      child: Consumer<JobDetailViewModel>(
        builder: (context, vm, _) {
          final job = vm.job;

          if (vm.isLoading) {
            return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator(color: kPrimaryColor)));
          }

          if (job == null) return _buildErrorState(context);

          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 220.0,
                    floating: false, pinned: true,
                    backgroundColor: kPrimaryColor,
                    leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    actions: [
                      IconButton(icon: Icon(vm.isSaved ? Icons.bookmark : Icons.bookmark_border, color: Colors.white), onPressed: () => vm.toggleSaveJob(context)),
                      // IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
                    ],
                    flexibleSpace: FlexibleSpaceBar(background: _buildHeaderContent(job)),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(controller: _tabController, labelColor: kPrimaryColor, unselectedLabelColor: Colors.grey, indicatorColor: kPrimaryColor, tabs: const [Tab(text: "Chi tiết"), Tab(text: "Công ty")]),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildJobInfo(context, vm, job),
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

  Widget _buildHeaderContent(JobEntity job) {
    String? logoUrl = job.company?.logoUrl;
    bool isValidUrl = logoUrl != null && logoUrl.isNotEmpty && logoUrl.startsWith('http');
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [kPrimaryColor, Color(0xFF5F27CD)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _navigateToCompany(context, job),
                child: Container(
                  width: 80, height: 80, padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)]),
                  child: isValidUrl ? Image.network(logoUrl, fit: BoxFit.contain) : const Icon(Icons.business, size: 40, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 12),
              Text(job.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobInfo(BuildContext context, JobDetailViewModel vm, JobEntity job) {
    List<String> displayTags = job.skills.isNotEmpty ? job.skills : (job.requirements?.split(', ') ?? []);
    String _formatSalary(double amount) => "\$${(amount/1000).toInt()}k";
    final String salaryText = (job.salaryMin != null && job.salaryMax != null) ? "${_formatSalary(job.salaryMin!)} - ${_formatSalary(job.salaryMax!)}" : (job.salaryMin != null ? "${_formatSalary(job.salaryMin!)} +" : "Thỏa thuận");

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildDetailBox(icon: Icons.attach_money, text: salaryText, color: Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildDetailBox(icon: Icons.work, text: job.jobType ?? "Full-time", color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDetailBox(icon: Icons.location_on, text: job.location ?? "Remote", color: Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildDetailBox(icon: Icons.calendar_today, text: "Hạn nộp", color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Mô tả công việc", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(job.description ?? 'Chưa có mô tả chi tiết.', style: const TextStyle(height: 1.6, fontSize: 15)),
          const SizedBox(height: 24),
          if (displayTags.isNotEmpty) ...[
            const Text("Kỹ năng yêu cầu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: displayTags.map((tag) => Chip(backgroundColor: kPrimaryColor.withOpacity(0.05), side: const BorderSide(color: kPrimaryColor), label: Text(tag, style: const TextStyle(color: kPrimaryColor)))).toList()),
          ],
          const SizedBox(height: 24),
          ChangeNotifierProvider.value(
            value: vm,
            child: CommentSection(jobId: job.jobId),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDetailBox({required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [Icon(icon, color: color, size: 24), const SizedBox(height: 4), Text(text, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)]),
    );
  }

  Widget _buildCompanyInfo(JobEntity job) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Thông tin doanh nghiệp", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildCompanyDetailRow(Icons.business, "Tên công ty", job.company?.name ?? "N/A"),
          const SizedBox(height: 12),
          _buildCompanyDetailRow(Icons.map, "Địa chỉ", job.company?.address ?? "Chưa cập nhật"),
          const SizedBox(height: 12),
          _buildCompanyDetailRow(Icons.language, "Website", job.company?.website ?? "Chưa cập nhật"),
          const Divider(height: 40),
          const Text("Giới thiệu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(job.company?.description ?? "Chưa có giới thiệu về công ty này.", style: const TextStyle(height: 1.5, fontSize: 15, color: Colors.black87), textAlign: TextAlign.justify),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, height: 50, child: OutlinedButton.icon(onPressed: () => _navigateToCompany(context, job), icon: const Icon(Icons.apartment, size: 20), label: const Text("Xem trang công ty & Việc làm khác", style: TextStyle(fontWeight: FontWeight.bold)), style: OutlinedButton.styleFrom(foregroundColor: kPrimaryColor, side: const BorderSide(color: kPrimaryColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCompanyDetailRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 20, color: kPrimaryColor), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(height: 2), Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))]))]);
  }

  // [UPDATED] Xử lý hiển thị nút dựa trên trạng thái trong ViewModel
  Widget _buildBottomAction(BuildContext context, JobDetailViewModel vm, JobEntity job) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
      child: SafeArea(
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: vm.isApplied
              // Nếu Đã ứng tuyển -> Hiển thị nút Hủy (Đỏ) và gọi dialog xác nhận
                  ? ElevatedButton(
                  onPressed: () => _showCancelConfirmation(context, vm),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text("Hủy ứng tuyển", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              )
              // Nếu Chưa ứng tuyển -> Hiển thị nút Ứng tuyển ngay (Tím)
                  : ElevatedButton(
                  onPressed: () => _showApplyBottomSheet(context, vm),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text("Ứng tuyển ngay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
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
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.search_off, size: 60, color: Colors.grey), const SizedBox(height: 16), Text("Không tìm thấy công việc:\n\"${widget.jobTitle}\"", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)), const SizedBox(height: 16), ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor), child: const Text("Quay lại", style: TextStyle(color: Colors.white)))])),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: Colors.white, child: _tabBar);
  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class ApplyJobForm extends StatefulWidget {
  const ApplyJobForm({super.key});
  @override State<ApplyJobForm> createState() => _ApplyJobFormState();
}

class _ApplyJobFormState extends State<ApplyJobForm> {
  int? _selectedCvId;
  final TextEditingController _coverLetterController = TextEditingController();

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JobDetailViewModel>();

    if (!vm.isLoadingCvs && vm.myCvs.isNotEmpty && _selectedCvId == null) {
      Future.microtask(() {
        if (mounted) {
          final defaultCv = vm.myCvs.firstWhere((cv) => cv.isDefault == true, orElse: () => vm.myCvs.first);
          setState(() => _selectedCvId = defaultCv.cvId);
        }
      });
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text("Ứng tuyển công việc", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text("Chọn hồ sơ (CV)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 10),
          Expanded(child: vm.isLoadingCvs ? const Center(child: CircularProgressIndicator(color: kPrimaryColor)) : vm.myCvs.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Bạn chưa có CV nào.", style: TextStyle(color: Colors.grey)), TextButton(onPressed: () { Navigator.pop(context); Navigator.pushNamed(context, '/manage_cv'); }, child: const Text("Tải lên CV ngay", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)))])) : ListView.builder(itemCount: vm.myCvs.length, itemBuilder: (context, index) { final cv = vm.myCvs[index]; final isSelected = _selectedCvId == cv.cvId; return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(border: Border.all(color: isSelected ? kPrimaryColor : Colors.grey.shade300, width: isSelected ? 2 : 1), borderRadius: BorderRadius.circular(12), color: isSelected ? kPrimaryColor.withOpacity(0.05) : Colors.white), child: RadioListTile<int>(title: Text(cv.title ?? "CV không tên", style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(cv.isDefault == true ? "Mặc định • ${cv.createdAt.toString().substring(0, 10)}" : "Ngày tải: ${cv.createdAt.toString().substring(0, 10)}", style: TextStyle(color: cv.isDefault == true ? kPrimaryColor : Colors.grey)), value: cv.cvId!, groupValue: _selectedCvId, activeColor: kPrimaryColor, onChanged: (val) => setState(() => _selectedCvId = val), secondary: const Icon(Icons.description, color: Colors.redAccent), contentPadding: const EdgeInsets.symmetric(horizontal: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))); })),
          const SizedBox(height: 16),
          const Text("Thư giới thiệu (Tùy chọn)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(controller: _coverLetterController, maxLines: 3, decoration: InputDecoration(hintText: "Viết vài dòng để gây ấn tượng...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: kPrimaryColor)), contentPadding: const EdgeInsets.all(12))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: (vm.isApplying || vm.myCvs.isEmpty || _selectedCvId == null) ? null : () async { final success = await vm.submitApplication(context, _selectedCvId, _coverLetterController.text); if (success && mounted) { Navigator.pop(context); _showSuccessDialog(context); } }, style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: vm.isApplying ? const CircularProgressIndicator(color: Colors.white) : const Text("Gửi hồ sơ", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(context: context, builder: (dialogContext) => AlertDialog(title: const Column(children: [Icon(Icons.check_circle, color: Colors.green, size: 60), SizedBox(height: 10), Text("Thành công!")]), content: const Text("Hồ sơ ứng tuyển của bạn đã được gửi.", textAlign: TextAlign.center), actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text("Đóng"))]));
  }
}