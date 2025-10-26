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
                  // TODO: Xử lý logic save
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
          bottomNavigationBar: _buildApplyButton(context, viewModel.job),
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

    return Column(
      children: [
        // Placeholder cho logo công ty
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: (companyName.isNotEmpty && companyName != 'N/A')
              ? Center(
            child: Text(
              companyName[0].toUpperCase(),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          )
              : Icon(Icons.business, color: Colors.grey.shade600, size: 40),
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

    // Tính lương. Ví dụ: "$16k"
    // Giả định salaryMax là USD và bạn muốn chia cho 1000
    // Nếu salaryMax là 16000, nó sẽ hiển thị là $16,000.
    // Ảnh của bạn ghi "$16k". Ta sẽ xử lý 1 chút
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

  Widget _buildApplyButton(BuildContext context, JobEntity? job) {
    if (job == null) return const SizedBox.shrink();

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
        onPressed: () {
          // TODO: Xử lý logic apply
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF00695C), // Màu teal đậm
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Apply this job',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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