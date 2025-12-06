// lib/views/login/user/job_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/job-entity.dart';
import '../../../view_models/user/job_detail_view_model.dart';
import '../../../utils/app_colors.dart';
import 'message_screen.dart';

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
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobDetailViewModel>(context, listen: false).fetchJobDetail(widget.jobTitle);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobDetailViewModel(), // Nếu chưa provide global
      child: Consumer<JobDetailViewModel>(
        builder: (context, vm, _) {
          final job = vm.job;
          if (vm.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          if (job == null) return const Scaffold(body: Center(child: Text("Job not found")));

          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: AppColors.primary,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [AppColors.primary, Color(0xFF312E81)], // Indigo to Dark Indigo
                              begin: Alignment.topCenter, end: Alignment.bottomCenter
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(image: NetworkImage(job.company?.logoUrl ?? ''), fit: BoxFit.contain)
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppColors.primary,
                        tabs: const [Tab(text: "Job Info"), Tab(text: "Company"), Tab(text: "Reviews")],
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
                  Center(child: Text("Company Info: ${job.company?.description}")),
                  const Center(child: Text("Reviews coming soon")),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomAction(context, vm),
          );
        },
      ),
    );
  }

  Widget _buildJobInfo(JobEntity job) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(job.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("\$${job.salaryMin} - \$${job.salaryMax}", style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          const Text("Job Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(job.description ?? '', style: const TextStyle(height: 1.5, fontSize: 15)),
          const SizedBox(height: 24),
          const Text("Requirements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(job.requirements ?? '', style: const TextStyle(height: 1.5, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, JobDetailViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () { /* Logic Chat */ },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Chat with Recruiter", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: vm.isApplied ? null : () => vm.applyForJob(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(vm.isApplied ? "Applied" : "Apply Now", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for Sticky TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}