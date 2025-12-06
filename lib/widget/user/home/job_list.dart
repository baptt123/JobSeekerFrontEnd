import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/user/home_view_model.dart';
import '../../../../view_models/user/save_job_view_model.dart';
import '../../../../views/login/user/job_detail_screen.dart';

class JobsList extends StatelessWidget {
  const JobsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sử dụng selector hoặc watch để lắng nghe thay đổi
    final homeViewModel = context.watch<HomeViewModel>();
    final savedJobsViewModel = context.read<SavedJobsViewModel>();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: homeViewModel.jobs.length,
      itemBuilder: (context, index) {
        final job = homeViewModel.jobs[index];
        final bool isSaved = homeViewModel.isJobSaved(job.jobId);

        final logoUrl = job.company?.logoUrl;
        final bool isUrlValid = logoUrl != null && logoUrl.startsWith('http');

        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailScreen(jobTitle: job.title),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo Công ty
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: isUrlValid
                          ? Image.network(logoUrl, fit: BoxFit.contain)
                          : Icon(Icons.business, color: Colors.grey[400]),
                    ),
                    const SizedBox(width: 16),

                    // Thông tin Job
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            job.company?.name ?? 'Công ty ẩn danh',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),

                          // Tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              if (job.location != null) _buildTag(Icons.location_on_outlined, job.location!),
                              if (job.jobType != null) _buildTag(Icons.access_time, job.jobType!),
                            ],
                          )
                        ],
                      ),
                    ),

                    // Nút Save
                    InkWell(
                      onTap: () {
                        homeViewModel.toggleSaveJob(job, context, savedJobsViewModel);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? const Color(0xFF00C89C) : Colors.grey[400],
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}