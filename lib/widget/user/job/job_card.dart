import 'package:flutter/material.dart';
import '../../../models/job-entity.dart';

class JobCard extends StatelessWidget {
  final JobEntity job;
  const JobCard({Key? key, required this.job}) : super(key: key);

  // [NEW] Hàm format tiền tệ VNĐ
  String _formatCurrency(double amount) {
    // 10000000 -> 10.000.000
    return amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final logoUrl = job.company?.logoUrl;
    // Kiểm tra URL hợp lệ
    final bool hasValidLogo = logoUrl != null &&
        logoUrl.isNotEmpty &&
        logoUrl.startsWith('http');

    // [UPDATED] Logic hiển thị lương theo định dạng VNĐ
    String salaryText;
    if (job.salaryMin != null && job.salaryMax != null) {
      salaryText = "${_formatCurrency(job.salaryMin!)} - ${_formatCurrency(job.salaryMax!)} VNĐ";
    } else if (job.salaryMin != null) {
      salaryText = "Từ ${_formatCurrency(job.salaryMin!)} VNĐ";
    } else {
      salaryText = "Thỏa thuận";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- LOGO CÔNG TY ---
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: hasValidLogo
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                logoUrl,
                fit: BoxFit.contain,
                errorBuilder: (ctx, err, stack) => const Center(
                  child: Icon(Icons.business, color: Colors.grey, size: 28),
                ),
              ),
            )
                : _buildFallbackIcon(job.company?.name),
          ),

          const SizedBox(width: 14),

          // --- NỘI DUNG ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên Job
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Tên Công ty
                Text(
                  job.company?.name ?? 'Công ty ẩn danh',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // Tags (Location, Salary, Type)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (job.location != null)
                      _buildTag(Icons.location_on_outlined, job.location!),

                    // [UPDATED] Hiển thị tag lương mới
                    _buildTag(
                        Icons.attach_money,
                        salaryText,
                        color: Colors.green.shade700,
                        bgColor: Colors.green.shade50
                    ),

                    if (job.jobType != null)
                      _buildTag(
                          Icons.access_time,
                          job.jobType!,
                          color: Colors.blue.shade700,
                          bgColor: Colors.blue.shade50
                      ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị logo dự phòng (Chữ cái đầu tên công ty)
  Widget _buildFallbackIcon([String? companyName]) {
    if (companyName != null && companyName.isNotEmpty) {
      return Center(
        child: Text(
          companyName[0].toUpperCase(),
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C63FF)
          ),
        ),
      );
    }
    // Logo mặc định nếu không có tên
    return const Icon(Icons.business, color: Colors.grey);
  }

  Widget _buildTag(IconData icon, String text, {Color? color, Color? bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: color ?? Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}