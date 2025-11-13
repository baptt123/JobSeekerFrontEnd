import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';

import '../../../view_models/user/save_job_view_model.dart';
import '../../../views/login/user/job_detail_screen.dart';
// import 'package:job_seeker_frontend/widget/user/suggest_job_card.dart';

// ⭐️ 1. IMPORT TRANG DETAIL
// (Path của bạn đã đúng)

class JobsList extends StatelessWidget {
  // ✅ 1. XÓA ScrollController
  // final ScrollController scrollController; (Không dùng nữa)

  // ✅ 2. CẬP NHẬT CONSTRUCTOR
  const JobsList({Key? key}) : super(key: key);
  // const JobsList({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();
    final savedJobsViewModel = context.read<SavedJobsViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListView.builder(
        // ✅ 3. XÓA CONTROLLER KHỎI LISTVIEW
        // controller: scrollController, (Không dùng nữa)
        itemCount: homeViewModel.jobs.length,
        itemBuilder: (context, index) {
          final job = homeViewModel.jobs[index];
          final bool isSaved = homeViewModel.isJobSaved(job.jobId);

          final logoUrl = job.company?.logoUrl;
          final bool isUrlValid = logoUrl != null &&
              logoUrl.isNotEmpty &&
              (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'));

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: isUrlValid ? NetworkImage(logoUrl) : null,
              child: !isUrlValid
                  ? Icon(Icons.business, color: Colors.grey[600])
                  : null,
            ),
            title: Text(job.title),
            subtitle: Text(job.company?.name ?? 'Chưa xác định'),
            trailing: IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? Colors.blue : Colors.grey,
              ),
              onPressed: () {
                homeViewModel.toggleSaveJob(job, context, savedJobsViewModel);
              },
            ),

            // --- HÀM ONTAP ĐIỀU HƯỚNG ---
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => JobDetailScreen(
                    // ⭐️ Gợi ý: Bạn nên truyền `jobId` hoặc toàn bộ object `job`
                    // thay vì chỉ `jobTitle`.
                    //
                    // Ví dụ 1: Truyền ID
                    // jobId: job.jobId,
                    //
                    // Ví dụ 2: Truyền cả object
                    // job: job,
                    //
                    // (Giữ nguyên code của bạn nếu JobDetailPage chỉ cần title)
                    jobTitle: job.title,
                  ),
                ),
              );
            },
            // --- KẾT THÚC THÊM MỚI ---
          );
        },
      ),
    );
  }
}