import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/models/job-entity.dart';

class SavedJobCard extends StatelessWidget {
  final JobEntity job;
  final VoidCallback onUnsavePressed;

  const SavedJobCard({
    Key? key,
    required this.job,
    required this.onUnsavePressed,
  }) : super(key: key);

  // Hàm helper để định dạng lương
  String _formatSalary() {
    if (job.salaryMin != null && job.salaryMax != null) {
      // Chuyển đổi số sang dạng tóm tắt (ví dụ: 15000 -> 15k)
      final min = (job.salaryMin! / 1000).toStringAsFixed(0);
      final max = (job.salaryMax! / 1000).toStringAsFixed(0);
      return '\$${min}k-\$${max}k/Month';
    } else if (job.salaryMin != null) {
      final min = (job.salaryMax! / 1000).toStringAsFixed(0);
      return '\$${min}k/Month';
    }
    // Giống trong ảnh, nếu không có lương thì hiển thị /Month
    return '/Month';
  }

  // Hàm helper để lấy logo (có xử lý null)
  String _getCompanyLogoUrl() {
    return job.company?.logoUrl ?? 'https://via.placeholder.com/150';
  }

  @override
  Widget build(BuildContext context) {
    // Màu teal/cyan từ ảnh
    const Color tagColor = Color(0xFF00B8A9);

    // Lấy thông tin từ JobEntity (có xử lý null)
    final companyName = job.company?.name ?? 'N/A';
    final companyLogoUrl = _getCompanyLogoUrl();
    final salary = _formatSalary();
    final location = job.location ?? 'N/A';

    // Tạo danh sách tags, ví dụ: ["Design", "Full Time", "Remote"]
    // Ở đây tôi dùng job_type làm ví dụ, bạn có thể thay bằng list tags thật
    final tags = [
      job.jobType ?? 'N/A',
      // Thêm các tags khác nếu có...
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng 1: Logo, Title, Nút Unsave
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  companyLogoUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      companyName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Nút Unsave (giống trong ảnh)
              GestureDetector(
                onTap: onUnsavePressed, // Gọi hàm được truyền vào
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bookmark_rounded, // Icon đã lưu
                    color: tagColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Hàng 2: Tags
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: tags
                .map((tag) => Chip(
              label: Text(
                tag,
                style: const TextStyle(color: tagColor, fontSize: 12),
              ),
              backgroundColor: tagColor.withOpacity(0.15),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              side: BorderSide.none,
            ))
                .toList(),
          ),
          const SizedBox(height: 16),
          // Hàng 3: Location và Salary
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.grey[500],
                size: 18,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                salary,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}