import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';

import '../../../view_models/user/save_job_view_model.dart';
import '../../../views/login/user/job_detail_screen.dart';
// import 'package:job_seeker_frontend/widget/user/suggest_job_card.dart';

// ⭐️ 1. ĐỪNG QUÊN IMPORT TRANG DETAIL CỦA BẠN
// (Hãy thay 'path/to' bằng đường dẫn đúng)

class JobsList extends StatelessWidget {
  final ScrollController scrollController;

  const JobsList({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();
    final savedJobsViewModel = context.read<SavedJobsViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListView.builder(
        controller: scrollController,
        itemCount: homeViewModel.jobs.length,
        itemBuilder: (context, index) {
          // (Bên trong hàm itemBuilder của ListView.builder)

          final job = homeViewModel.jobs[index];
          final bool isSaved = homeViewModel.isJobSaved(job.jobId);

          // Lấy URL logo (dùng cấu trúc lồng nhau như cũ)
          final logoUrl = job.company?.logoUrl; // <-- Vẫn hoạt động!

          // Kiểm tra (vì logo_url có thể là 'Tạm thời chưa cập nhật')
          final bool isUrlValid =
              logoUrl != null &&
                  logoUrl.isNotEmpty &&
                  (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'));

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: isUrlValid ? NetworkImage(logoUrl!) : null,
              child: !isUrlValid
                  ? Icon(Icons.business, color: Colors.grey[600])
                  : null,
            ),

            // --- 2. SỬA TITLE VÀ SUBTITLE ---
            title: Text(job.title),
            subtitle: Text(job.company?.name ?? 'Chưa xác định'),
            // Sửa lại theo DTO mới

            // --- 3. GIỮ NGUYÊN TRAILING (BOOKMARK) ---
            trailing: IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? Colors.blue : Colors.grey,
              ),
              onPressed: () {
                homeViewModel.toggleSaveJob(job, context, savedJobsViewModel);
              },
            ),

            // ⭐️ 2. THÊM HÀM ONTAP ĐỂ ĐIỀU HƯỚNG
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => JobDetailPage(
                    // Truyền title của job này qua
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