// lib/views/login/user/job_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/job-entity.dart';
import '../../../view_models/user/job_detail_view_model.dart';

// Đảm bảo bạn đã import đúng các model và ViewModel
// import '../../../models/company-entity.dart'; (Nếu cần)

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

class _JobDetailViewBodyState extends State<_JobDetailViewBody>
    with TickerProviderStateMixin {
  bool _isDescriptionExpanded = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch data ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobDetailViewModel>(context, listen: false)
          .fetchJobDetail(widget.jobTitle);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ⭐️ HÀM 1: TÍNH TOÁN TEXT HIỂN THỊ (VD: "20 days left")
  String _getDeadlineText(DateTime? deadline) {
    if (deadline == null) return 'N/A';

    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'Expired'; // Đã hết hạn
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days left'; // Còn trên 1 ngày
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours left'; // Còn vài giờ
    } else {
      return 'Closing soon'; // Sắp đóng trong vài phút
    }
  }

  // ⭐️ HÀM 2: KIỂM TRA XEM ĐÃ HẾT HẠN CHƯA
  bool _isJobExpired(DateTime? deadline) {
    if (deadline == null) return false;
    return deadline.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobDetailViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context, viewModel),
          body: _buildBody(context, viewModel),
          bottomNavigationBar: _buildApplyButton(context, viewModel),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, JobDetailViewModel viewModel) {
    return AppBar(
      title: const Text('Job Detail'),
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        // Nút Save
        IconButton(
          icon: Icon(
            viewModel.isSaved ? Icons.bookmark : Icons.bookmark_border_outlined,
            color: viewModel.isSaved ? Colors.blue : Colors.grey,
          ),
          onPressed: viewModel.isSaving
              ? null
              : () => viewModel.toggleSaveJob(context),
        ),
        // Nút Share
        IconButton(
          icon: const Icon(Icons.ios_share_outlined),
          onPressed: () {
            // Logic share
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, JobDetailViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: ${viewModel.errorMessage}'),
        ),
      );
    }

    if (viewModel.job == null) {
      return const Center(child: Text('Job not found.'));
    }

    final job = viewModel.job!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, job),
          const SizedBox(height: 24),
          _buildInfoTags(context, job), // ⭐️ Tag chứa Deadline
          const SizedBox(height: 24),
          _buildTabs(context, job),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, JobEntity job) {
    final companyName = job.company?.name ?? 'Unknown Company';
    final logoUrl = job.company?.logoUrl;

    final bool isUrlValid = logoUrl != null &&
        logoUrl.isNotEmpty &&
        (logoUrl.startsWith('http') || logoUrl.startsWith('https'));

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: isUrlValid ? NetworkImage(logoUrl!) : null,
            child: !isUrlValid
                ? Icon(Icons.business, color: Colors.grey[400], size: 40)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          job.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          companyName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ⭐️ WIDGET HIỂN THỊ INFO TAGS (BAO GỒM DEADLINE)
  Widget _buildInfoTags(BuildContext context, JobEntity job) {
    final currencyFormatter =
    NumberFormat.simpleCurrency(locale: 'en_US', decimalDigits: 0);

    // Format lương
    final salary = (job.salaryMax != null)
        ? '\$${(job.salaryMax! / 1000).toStringAsFixed(0)}k/mo'
        : (job.salaryMin != null)
        ? '${currencyFormatter.format(job.salaryMin)}/mo'
        : 'Negotiable';

    // ⭐️ Logic UI cho Deadline
    final isExpired = _isJobExpired(job.deadline);
    final deadlineText = _getDeadlineText(job.deadline);

    // Màu sắc dựa trên trạng thái
    final deadlineColor = isExpired ? Colors.red.shade700 : const Color(0xFFE65100); // Cam đậm
    final deadlineBg = isExpired ? Colors.red.shade50 : const Color(0xFFFFF3E0); // Cam nhạt

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _InfoTag(
            icon: Icons.location_on_outlined,
            text: job.location ?? 'Remote',
          ),
          const SizedBox(width: 10),
          _InfoTag(
            icon: Icons.attach_money,
            text: salary,
          ),
          const SizedBox(width: 10),
          _InfoTag(
            icon: Icons.work_outline,
            text: job.jobType ?? 'Full-time',
          ),
          const SizedBox(width: 10),

          // ⭐️ TAG DEADLINE MỚI
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: deadlineBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_filled, size: 16, color: deadlineColor),
                const SizedBox(width: 6),
                Text(
                  deadlineText,
                  style: TextStyle(
                    color: deadlineColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, JobEntity job) {
    return Column(
      children: [
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Theme.of(context).primaryColor,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Detail'),
              Tab(text: 'Company'),
              Tab(text: 'Reviews'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 500, // Chiều cao cho nội dung tab
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDescriptionTab(context, job),
              _buildCompanyTab(context, job),
              const Center(child: Text("Reviews coming soon")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionTab(BuildContext context, JobEntity job) {
    final requirementsList = (job.requirements ?? '')
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim().replaceAll(RegExp(r'^-\s*'), ''))
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Job Description",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            job.description ?? 'No description available.',
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            maxLines: _isDescriptionExpanded ? null : 4,
            overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          TextButton(
            onPressed: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
            child: Text(_isDescriptionExpanded ? "Read Less" : "Read More"),
          ),
          const SizedBox(height: 20),
          if (requirementsList.isNotEmpty) ...[
            const Text(
              "Requirements",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...requirementsList.map((req) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 20, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 10),
                  Expanded(child: Text(req, style: TextStyle(color: Colors.grey.shade700))),
                ],
              ),
            )),
          ]
        ],
      ),
    );
  }

  Widget _buildCompanyTab(BuildContext context, JobEntity job) {
    final company = job.company;
    if (company == null) return const Center(child: Text("No company info"));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("About Company", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(company.description ?? 'No description', style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.language, color: Colors.blue),
            ),
            title: const Text("Website"),
            subtitle: Text(company.website ?? "Not provided"),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.location_on, color: Colors.orange),
            ),
            title: const Text("Address"),
            subtitle: Text(company.address ?? "Not provided"),
          ),
        ],
      ),
    );
  }

  // ⭐️ NÚT APPLY (LOGIC: DISABLE NẾU HẾT HẠN)
  Widget _buildApplyButton(BuildContext context, JobDetailViewModel viewModel) {
    if (viewModel.job == null) return const SizedBox.shrink();

    final job = viewModel.job!;
    final bool isExpired = _isJobExpired(job.deadline);
    final bool hasApplied = viewModel.isApplied;
    final bool isProcessing = viewModel.isApplying;

    // 1. Xác định Text và Màu sắc
    String buttonText;
    Color buttonColor;

    if (hasApplied) {
      buttonText = "Applied";
      buttonColor = Colors.grey;
    } else if (isExpired) {
      buttonText = "Expired";
      buttonColor = Colors.red.shade400;
    } else {
      buttonText = "Apply Now";
      buttonColor = const Color(0xFF00695C); // Màu xanh chủ đạo
    }

    // 2. Xác định trạng thái Disable
    final bool isDisabled = hasApplied || isExpired || isProcessing;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () => viewModel.applyForJob(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          disabledBackgroundColor: buttonColor.withOpacity(0.6), // Giữ màu nhưng nhạt hơn khi disable
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isProcessing
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
          buttonText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

// Widget Tag nhỏ (Helper)
class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}