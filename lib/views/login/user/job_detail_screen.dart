import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/job-entity.dart';
import '../../../view_models/user/job_detail_view_model.dart';

// Đây là file view chính, nó sẽ khởi tạo ViewModel
class JobDetailPage extends StatelessWidget {
  final String jobTitle;
  const JobDetailPage({super.key, required this.jobTitle});

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
              IconButton(
                // Icon "save" trong ảnh
                icon: const Icon(Icons.bookmark_border_outlined),
                onPressed: () {
                  // TODO: Xử lý logic save (sẽ cần tích hợp giống apply)
                },
              ),
              IconButton(
                // Icon "upload/share" trong ảnh
                icon: const Icon(Icons.ios_share_outlined),
                onPressed: () {
                  // TODO: Xử lý logic share
                },
              ),
            ],
          ),
          body: _buildBody(context, viewModel),
          // Nút "Apply this job" ở dưới cùng
          // ⭐️ SỬA: Truyền cả viewModel
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
          _buildHeader(context, job),
          const SizedBox(height: 24),
          _buildInfoTags(context, job),
          const SizedBox(height: 24),
          _buildTabs(context, job),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, JobEntity job) {
    final companyName = job.company?.name ?? 'N/A';

    // ⭐️ SỬA: Thêm logic lấy logo
    final logoUrl = job.company?.logoUrl;
    final bool isUrlValid =
        logoUrl != null &&
            logoUrl.isNotEmpty &&
            (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'));

    return Column(
      children: [
        // ⭐️ SỬA: Hiển thị logo thật (CircleAvatar)
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
        // Dùng IndexedStack hoặc TabBarView để hiển thị nội dung tab
        SizedBox(
          // Chiều cao cho nội dung tab. Có thể dùng cách khác nếu nội dung động
          height: 400, // TODO: Điều chỉnh chiều cao này
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDescriptionTab(context, job),
              _buildCompanyTab(context, job),
              _buildReviewsTab(context, job),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionTab(BuildContext context, JobEntity job) {
    // Tách các yêu cầu (requirements)
    final requirementsList = (job.requirements ?? '')
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim().replaceFirst(RegExp(r'^-\s*'), '')) // Bỏ dấu "-"
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần mô tả (Read More)
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

          // Phần Responsibilities
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

  Widget _buildCompanyTab(BuildContext context, JobEntity job) {
    return SingleChildScrollView(
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
            job.company?.description ?? 'No company description available.',
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
          // Thêm các thông tin khác của công ty nếu muốn
          // ví dụ: job.company?.website
        ],
      ),
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

  // ⭐️ SỬA: Thay JobEntity? job bằng JobDetailViewModel viewModel
// ... (bên trong _JobDetailViewBodyState)

  Widget _buildApplyButton(BuildContext context, JobDetailViewModel viewModel) {
    if (viewModel.job == null) return const SizedBox.shrink();

    // ⭐️ LOGIC MỚI: Xác định trạng thái nút
    final bool hasApplied = viewModel.isApplied; // Lấy từ VM
    final bool isProcessing = viewModel.isApplying;

    // Xác định text, màu sắc và trạng thái disable
    final String buttonText = hasApplied ? 'Đã Nộp Đơn' : 'Apply this job';

    final Color buttonColor = hasApplied
        ? Colors.grey.shade600 // Màu xám nếu đã nộp
        : const Color(0xFF00695C); // Màu teal

    final bool isDisabled = isProcessing || hasApplied; // Disable nếu đang xử lý HOẶC đã nộp

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
        // ⭐️ SỬA: Dùng cờ isDisabled
        onPressed: isDisabled
            ? null // Vô hiệu hóa nút
            : () {
          viewModel.applyForJob(context);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          // ⭐️ SỬA: Dùng màu động
          backgroundColor: buttonColor,
          // ⭐️ THÊM: Màu khi bị vô hiệu hóa (sẽ tự động dùng màu xám)
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // ⭐️ SỬA: Check cờ isProcessing
        child: isProcessing
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        )
        // ⭐️ SỬA: Dùng text động
            : Text(
          buttonText,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }
}

// Widget phụ trợ cho tag (Location, Salary, Type)
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

// Widget phụ trợ cho mục "Responsibilities"
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