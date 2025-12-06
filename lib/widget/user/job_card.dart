import 'package:flutter/material.dart';
import '../../models/job-entity.dart';
import '../../utils/app_colors.dart';

class JobCard extends StatelessWidget {
  final JobEntity job;
  const JobCard({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kiểm tra chế độ tối/sáng
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final companyName = job.company?.name ?? 'Unknown';
    final logoUrl = job.company?.logoUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo công ty
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                  image: (logoUrl != null && logoUrl.isNotEmpty)
                      ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.contain)
                      : null,
                ),
                child: (logoUrl == null || logoUrl.isEmpty)
                    ? const Icon(Icons.business, color: Colors.grey) : null,
              ),
              const SizedBox(width: 16),

              // Thông tin chính
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.backgroundDark,
                      ),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      companyName,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: isDark ? Colors.grey : Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job.location ?? 'Remote',
                            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey : Colors.grey.shade600),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // Icon Bookmark
              Icon(
                job.isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: job.isSaved ? AppColors.primary : Colors.grey,
                size: 26,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chips (Lương & Loại công việc)
          Row(
            children: [
              _buildBadge(
                text: _formatSalary(job.salaryMin, job.salaryMax),
                bgColor: Colors.green.withOpacity(0.1),
                textColor: Colors.green,
              ),
              const SizedBox(width: 12),
              _buildBadge(
                text: job.jobType ?? 'Full-time',
                bgColor: Colors.transparent,
                textColor: isDark ? Colors.white70 : Colors.black54,
                hasBorder: true,
                borderColor: isDark ? Colors.white24 : Colors.grey.shade300,
              ),
            ],
          )
        ],
      ),
    );
  }

  String _formatSalary(double? min, double? max) {
    if (min == null && max == null) return "Negotiable";
    if (min != null && max != null) return "\$${(min/1000).toInt()}k - \$${(max/1000).toInt()}k";
    return "\$${(min ?? max)!/1000}k+";
  }

  Widget _buildBadge({required String text, required Color bgColor, required Color textColor, bool hasBorder = false, Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: hasBorder ? Border.all(color: borderColor!) : null,
      ),
      child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}