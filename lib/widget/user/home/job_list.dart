// lib/widget/user/home/job_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';
import '../../../view_models/user/save_job_view_model.dart';
import '../../../views/login/user/job_detail_screen.dart'; // ✅ Import Detail Screen

class JobsList extends StatelessWidget {
  const JobsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();
    final savedJobsViewModel = context.read<SavedJobsViewModel>();

    // Sử dụng shrinkWrap và physics để hoạt động tốt trong SingleChildScrollView của Home
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      shrinkWrap: true, // ✅ Quan trọng để nằm trong ScrollView
      physics: const NeverScrollableScrollPhysics(), // ✅ Quan trọng
      itemCount: homeViewModel.jobs.length,
      itemBuilder: (context, index) {
        final job = homeViewModel.jobs[index];
        final bool isSaved = homeViewModel.isJobSaved(job.jobId);

        final logoUrl = job.company?.logoUrl;
        final bool isUrlValid = logoUrl != null &&
            logoUrl.isNotEmpty &&
            (logoUrl.startsWith('http') || logoUrl.startsWith('https'));

        // ✅ Bọc Card trong InkWell/GestureDetector
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // ✅ CHUYỂN HƯỚNG SANG CHI TIẾT JOB
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailScreen(
                    jobTitle: job.title, // Truyền title để API lấy detail
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      image: isUrlValid
                          ? DecorationImage(
                          image: NetworkImage(logoUrl!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: !isUrlValid
                        ? Icon(Icons.business, color: Colors.grey[400])
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Nội dung text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.company?.name ?? 'Unknown Company',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Tags (Lương, Location, Type)
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (job.location != null)
                              _buildTag(job.location!),
                            if (job.jobType != null)
                              _buildTag(job.jobType!),
                          ],
                        )
                      ],
                    ),
                  ),

                  // Nút Save
                  IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? Colors.blue : Colors.grey,
                    ),
                    onPressed: () {
                      homeViewModel.toggleSaveJob(
                          job, context, savedJobsViewModel);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
      ),
    );
  }
}