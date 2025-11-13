// lib/views/login/user/job_detail_screen.dart
// (File này được cập nhật dựa trên code của bạn)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/job-entity.dart';
import '../../../view_models/user/job_detail_view_model.dart';
// ⭐️ Import cả model company

// Đây là file view chính, nó sẽ khởi tạo ViewModel
class JobDetailScreen extends StatelessWidget {
  final String jobTitle;
  const JobDetailScreen({super.key, required this.jobTitle});

  @override
  Widget build(BuildContext context) {
    // Sử dụng ChangeNotifierProvider để tạo và cung cấp ViewModel
    // cho cây widget con (ở đây là _JobDetailViewBody)
    return ChangeNotifierProvider(
      create: (_) => JobDetailViewModel(),
      child: _JobDetailViewBody(jobTitle: jobTitle),
    );
  }
}

// Widget con này là một StatefulWidget để nó có thể gọi
// hàm fetch data trong initState
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

    // Ngay khi widget được tạo, gọi ViewModel để fetch data
    // Dùng listen: false vì ta chỉ muốn gọi hàm, không cần lắng nghe thay đổi ở đây
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

  @override
  Widget build(BuildContext context) {
    // Dùng Consumer để lắng nghe thay đổi từ ViewModel và rebuild UI
    return Consumer<JobDetailViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Job Detail'),
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              // Icon "Save" (Giữ nguyên)
              IconButton(
                icon: Icon(
                  viewModel.isSaved
                      ? Icons.bookmark
                      : Icons.bookmark_border_outlined,
                  color: viewModel.isSaved ? Colors.blue : Colors.grey,
                ),
                onPressed: viewModel.isSaving
                    ? null
                    : () {
                  viewModel.toggleSaveJob(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.ios_share_outlined),
                onPressed: () {
                  // TODO: Xử lý logic share
                },
              ),
            ],
          ),
          body: _buildBody(context, viewModel),
          bottomNavigationBar: _buildApplyButton(context, viewModel),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, JobDetailViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return Center(
        child: Text('Đã xảy ra lỗi: ${viewModel.errorMessage}'),
      );
    }

    if (viewModel.job == null) {
      return const Center(child: Text('Không tìm thấy dữ liệu công việc.'));
    }

    // Khi đã có data (viewModel.job)
    final job = viewModel.job!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, job), // ⭐️ ĐÃ CẬP NHẬT
          const SizedBox(height: 24),
          _buildInfoTags(context, job),
          const SizedBox(height: 24),
          _buildTabs(context, job), // ⭐️ ĐÃ CẬP NHẬT
        ],
      ),
    );
  }

  // ⭐️⭐️⭐️ PHƯƠNG THỨC NÀY ĐÃ ĐƯỢC CẬP NHẬT ⭐️⭐️⭐️
  Widget _buildHeader(BuildContext context, JobEntity job) {
    // Lấy thông tin công ty từ job.company (đã được eager load từ backend)
    final companyName = job.company?.name ?? 'N/A';
    final logoUrl = job.company?.logoUrl;

    final bool isUrlValid = logoUrl != null &&
        logoUrl.isNotEmpty &&
        (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'));

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[200],
          backgroundImage: isUrlValid ? NetworkImage(logoUrl!) : null,
          child: !isUrlValid
              ? Icon(Icons.business, color: Colors.grey[600], size: 40)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          job.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          companyName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTags(BuildContext context, JobEntity job) {
    // (Giữ nguyên logic của bạn)
    final currencyFormatter =
    NumberFormat.simpleCurrency(locale: 'en_US', decimalDigits: 0);

    final salary = (job.salaryMax != null)
        ? '\$${(job.salaryMax! / 1000).toStringAsFixed(0)}k /Mo'
        : (job.salaryMin != null)
        ? '${currencyFormatter.format(job.salaryMin)} /Mo'
        : 'N/A';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _InfoTag(
          icon: Icons.location_on,
          text: job.location ?? 'N/A',
        ),
        const SizedBox(width: 12),
        _InfoTag(
          icon: Icons.attach_money,
          text: salary,
        ),
        const SizedBox(width: 12),
        _InfoTag(
          icon: Icons.timer,
          text: job.jobType ?? 'N/A',
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context, JobEntity job) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Job Descriptions'),
            Tab(text: 'Company'),
            Tab(text: 'Reviews'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          // ⭐️ Tăng chiều cao để chứa nội dung công ty
          height: 600, // TODO: Điều chỉnh chiều cao này nếu cần
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDescriptionTab(context, job),
              _buildCompanyTab(context, job), // ⭐️ ĐÃ CẬP NHẬT
              _buildReviewsTab(context, job),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionTab(BuildContext context, JobEntity job) {
    // (Giữ nguyên logic của bạn)
    final requirementsList = (job.requirements ?? '')
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim().replaceFirst(RegExp(r'^-\s*'), ''))
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.topCenter,
            child: Text(
              job.description ?? 'No description provided.',
              maxLines: _isDescriptionExpanded ? null : 4,
              overflow: _isDescriptionExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700, height: 1.5),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Text(_isDescriptionExpanded ? 'Read Less' : 'Read More'),
          ),
          const SizedBox(height: 24),
          Text(
            'Responsibilities',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...requirementsList.map((item) => _ResponsibilityItem(text: item)),
        ],
      ),
    );
  }

  // ⭐️⭐️⭐️ PHƯƠNG THỨC NÀY ĐÃ ĐƯỢC CẬP NHẬT HOÀN TOÀN ⭐️⭐️⭐️
  Widget _buildCompanyTab(BuildContext context, JobEntity job) {
    final company = job.company; // Lấy object company từ job

    // Nếu không có thông tin công ty (dù đã eager load)
    if (company == null) {
      return const Center(
        child: Text(
          'Company information is not available.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Hiển thị thông tin công ty
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Company',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            company.description ?? 'No description provided.',
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 24),

          // Hiển thị Website và Địa chỉ
          _buildCompanyInfoRow(
            context,
            icon: Icons.public,
            title: 'Website',
            content: company.website,
          ),
          const SizedBox(height: 16),
          _buildCompanyInfoRow(
            context,
            icon: Icons.location_on_outlined,
            title: 'Address',
            content: company.address,
          ),
        ],
      ),
    );
  }

  // ⭐️⭐️⭐️ WIDGET PHỤ TRỢ MỚI CHO TAB CÔNG TY ⭐️⭐️⭐️
  Widget _buildCompanyInfoRow(BuildContext context,
      {required IconData icon, required String title, String? content}) {

    final bool hasContent = content != null && content.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasContent ? content : 'Not provided',
                style: TextStyle(
                    color: hasContent ? Colors.grey.shade700 : Colors.grey.shade400,
                    height: 1.4,
                    fontStyle: hasContent ? FontStyle.normal : FontStyle.italic
                ),
                // Cân nhắc thêm:
                // onTap: (title == 'Website' && hasContent) ? () {
                //   _launchURL(content); // Cần một hàm để mở URL
                // } : null,
                // style: TextStyle(
                //   color: (title == 'Website' && hasContent) ? Colors.blue : Colors.grey.shade700,
                //   decoration: (title == 'Website' && hasContent) ? TextDecoration.underline : TextDecoration.none,
                // ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab(BuildContext context, JobEntity job) {
    return const Center(
      child: Text(
        'Reviews (Chưa có dữ liệu)',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context, JobDetailViewModel viewModel) {
    // (Giữ nguyên logic của bạn)
    if (viewModel.job == null) return const SizedBox.shrink();

    final bool hasApplied = viewModel.isApplied;
    final bool isProcessing = viewModel.isApplying;
    final String buttonText = hasApplied ? 'Đã Nộp Đơn' : 'Apply this job';
    final Color buttonColor =
    hasApplied ? Colors.grey.shade600 : const Color(0xFF00695C);
    final bool isDisabled = isProcessing || hasApplied;

    return Container(
      padding: const EdgeInsets.all(16.0).copyWith(
        bottom: 16.0 + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () {
          viewModel.applyForJob(context);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: buttonColor,
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isProcessing
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        )
            : Text(
          buttonText,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }
}

// Widget phụ trợ (Giữ nguyên)
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget phụ trợ (Giữ nguyên)
class _ResponsibilityItem extends StatelessWidget {
  final String text;
  const _ResponsibilityItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}