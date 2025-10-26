import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/job-entity.dart';
import '../../views/login/user/job_detail_screen.dart';
// Import trang detail view mới của bạn

class SuggestedJobCard extends StatelessWidget {
  final JobEntity job;
  const SuggestedJobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
    NumberFormat.simpleCurrency(locale: 'en_US', decimalDigits: 0);
    final salary = currencyFormatter.format(job.salaryMax ?? job.salaryMin ?? 0);
    final companyName = job.company?.name ?? 'N/A';

    // BỌC TRONG INKWELL ĐỂ CÓ THỂ NHẤN VÀO
    return InkWell(
      onTap: () {
        // HÀNH ĐỘNG ĐIỀU HƯỚNG
        Navigator.push(
          context,
          MaterialPageRoute(
            // Truyền 'job.title' sang trang chi tiết
            builder: (context) => JobDetailPage(jobTitle: job.title),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16), // Cho hiệu ứng splash đẹp
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: (companyName.isNotEmpty && companyName != 'N/A')
                      ? Center(
                    child: Text(
                      companyName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                      : Icon(Icons.business, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        companyName,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.bookmark_border_outlined,
                    color: Colors.grey.shade600),
              ],
            ),
            const SizedBox(height: 16),
            if (job.jobType != null && job.jobType!.isNotEmpty)
              _buildTag(job.jobType!)
            else
              const SizedBox(height: 8),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  job.location ?? 'N/A',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  '$salary/Month',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Color(0xFF00695C), fontWeight: FontWeight.w500),
      ),
    );
  }
}