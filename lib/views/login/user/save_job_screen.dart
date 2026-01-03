import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/save_job_view_model.dart';
import '../../../view_models/user/home_view_model.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({Key? key}) : super(key: key);
  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedJobsViewModel>().fetchSavedJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BỎ backgroundColor cứng
      appBar: AppBar(
        title: Text("Công việc đã lưu", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white)),
        centerTitle: true,
        // AppBar dùng Theme mặc định
      ),
      body: Consumer<SavedJobsViewModel>(
        builder: (context, vm, _) {
          if (vm.state == SavedJobsState.loading) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          if (vm.state == SavedJobsState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    "Lỗi tải dữ liệu: ${vm.error}",
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => vm.fetchSavedJobs(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Thử lại"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                    ),
                  )
                ],
              ),
            );
          }

          if (vm.state == SavedJobsState.unauthorized) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text("Vui lòng đăng nhập để xem công việc đã lưu"),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text("Đăng nhập ngay", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          }

          if (vm.savedJobs.isEmpty) return _buildEmptyState();

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: vm.savedJobs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (ctx, index) {
              final job = vm.savedJobs[index];
              final logoUrl = job.company?.logoUrl;
              final bool hasValidLogo = logoUrl != null && logoUrl.isNotEmpty && logoUrl.startsWith('http');
              final salaryText = (job.salaryMin != null && job.salaryMax != null)
                  ? "\$${job.salaryMin} - \$${job.salaryMax}"
                  : "Thỏa thuận";

              return Dismissible(
                key: Key(job.jobId.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
                ),
                onDismissed: (_) => vm.unsaveJob(job, context, context.read<HomeViewModel>()),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color, // Tự động đổi màu
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white, // Logo để nền trắng
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: hasValidLogo
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(logoUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.business, color: Colors.grey)),
                        )
                            : const Icon(Icons.business, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(job.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(job.company?.name ?? "Unknown", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(salaryText, style: const TextStyle(color: kPrimaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
                          )
                        ]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark, color: kPrimaryColor),
                        onPressed: () => vm.unsaveJob(job, context, context.read<HomeViewModel>()),
                      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Chưa có công việc nào được lưu", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}