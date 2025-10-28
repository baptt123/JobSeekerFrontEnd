import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';

import '../../../view_models/user/save_job_view_model.dart';
// Bạn có thể dùng Card tùy chỉnh của mình ở đây
// import 'package:job_seeker_frontend/widget/user/suggest_job_card.dart';

class JobsList extends StatelessWidget {
  // 1. Nhận ScrollController
  final ScrollController scrollController;

  const JobsList({
    Key? key,
    required this.scrollController, // 2. Yêu cầu controller
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy các ViewModel từ context
    final homeViewModel = context.watch<HomeViewModel>();
    final savedJobsViewModel = context.read<SavedJobsViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListView.builder(
        // 3. GÁN controller cho ListView
        controller: scrollController,
        itemCount: homeViewModel.jobs.length,
        itemBuilder: (context, index) {
          // Lấy job hiện tại
          final job = homeViewModel.jobs[index];
          // Kiểm tra trạng thái đã lưu
          final bool isSaved = homeViewModel.isJobSaved(job.jobId);

          // Trả về widget cho mỗi item (Bạn có thể thay ListTile bằng SuggestJobCard)
          return ListTile(
            title: Text(job.title),
            subtitle: Text(job.company?.name ?? 'N/A'),
            trailing: IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? Colors.blue : Colors.grey,
              ),
              onPressed: () {
                // Gọi hàm toggle
                homeViewModel.toggleSaveJob(
                  job,
                  context,
                  savedJobsViewModel,
                );
              },
            ),
          );
        },
      ),
    );
  }
}