import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/save_job_view_model.dart';
import '../../../view_models/user/home_view_model.dart';
import '../../../widget/user/save_job/save_job_card.dart'; // Giả sử bạn đã update JobCard hoặc dùng JobCard chung
import '../../../utils/app_colors.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({Key? key}) : super(key: key);
  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SavedJobsViewModel>().fetchSavedJobs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Jobs"),
        centerTitle: true,
      ),
      body: Consumer<SavedJobsViewModel>(
        builder: (context, vm, _) {
          if (vm.state == SavedJobsState.loading) return const Center(child: CircularProgressIndicator());
          if (vm.state == SavedJobsState.unauthorized) return _buildGuestState();
          if (vm.savedJobs.isEmpty) return const Center(child: Text("No saved jobs yet"));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.savedJobs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (ctx, index) {
              final job = vm.savedJobs[index];
              // Tái sử dụng JobCard đã update ở bước trước, hoặc tạo SavedJobCard tương tự
              // Để đơn giản, ta dùng layout tùy chỉnh ở đây
              return Dismissible(
                key: Key(job.jobId.toString()),
                direction: DismissDirection.endToStart,
                background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                onDismissed: (_) => vm.unsaveJob(job, context, context.read<HomeViewModel>()),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                        child: job.company?.logoUrl != null ? Image.network(job.company!.logoUrl!) : const Icon(Icons.business),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(job.company?.name ?? "Unknown", style: const TextStyle(color: Colors.grey)),
                        ]),
                      ),
                      const Icon(Icons.bookmark, color: AppColors.primary),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGuestState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Login to view saved jobs"),
          TextButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text("Login Now"))
        ],
      ),
    );
  }
}