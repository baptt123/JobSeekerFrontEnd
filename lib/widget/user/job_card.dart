// lib/views/widgets/job_card.dart
import 'package:flutter/material.dart';

import '../../models/job-entity.dart';
// Đảm bảo bạn import đúng đường dẫn đến JobEntity
// Và CompanyEntity nếu JobEntity cần
// import '../../models/company_entity.dart';

// URL dự phòng nếu logo công ty bị null
const String _logoPlaceholder = 'https://via.placeholder.com/50';

class JobCard extends StatelessWidget {
  final JobEntity job;
  const JobCard({Key? key, required this.job}) : super(key: key);

  /// Helper để định dạng lương từ salaryMin và salaryMax
  String _formatSalary(double? min, double? max) {
    // Ưu tiên hiển thị cả hai nếu có
    if (min != null && max != null) {
      // Nếu min và max bằng nhau, chỉ hiển thị một số
      if (min == max) {
        return '\$${min.toStringAsFixed(0)}/Month';
      }
      return '\$${min.toStringAsFixed(0)} - \$${max.toStringAsFixed(0)}/Month';
    }
    // Nếu chỉ có min
    if (min != null) {
      return 'From \$${min.toStringAsFixed(0)}/Month';
    }
    // Nếu chỉ có max
    if (max != null) {
      return 'Up to \$${max.toStringAsFixed(0)}/Month';
    }
    // Nếu không có cả hai
    return 'Thương lượng';
  }

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu từ nested company entity, xử lý null
    final companyName = job.company?.name ?? 'Công ty không rõ';
    final companyLogoUrl = job.company?.logoUrl ?? _logoPlaceholder;

    // Lấy màu dựa trên tên công ty
    final cardColor = _getCardColor(companyName);
    final tagColor = _getTagColor(companyName);

    // --- Xử lý Tags ---
    // Entity của bạn chỉ có 'jobType'. Ảnh gốc có nhiều tags hơn
    // (như category và workModel). Chúng ta sẽ chỉ hiển thị những gì có.
    final List<String> tags = [];
    if (job.jobType != null && job.jobType!.isNotEmpty) {
      tags.add(job.jobType!);
    }
    // Bạn có thể thêm các trường khác vào đây nếu entity có
    // ví dụ: if (job.workModel != null) tags.add(job.workModel!);
    // ví dụ: if (job.category != null) tags.add(job.category!);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng 1: Logo, Title, Bookmark
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Image.network(
                    companyLogoUrl, // Cập nhật từ company entity
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator(strokeWidth: 2));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.business, color: Colors.grey.shade300);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Title & Company
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title, // Giữ nguyên
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        companyName, // Cập nhật từ company entity
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bookmark Icon
                Icon(
                  Icons.bookmark_border_rounded,
                  color: Colors.grey.shade500,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hàng 2: Tags
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              // Hiển thị các tag có trong list
              children: tags.map((tag) => _buildTag(tag, tagColor)).toList(),
            ),
            const SizedBox(height: 16),

            // Hàng 3: Location & Salary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.location ?? 'Không rõ', // Xử lý null
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatSalary(job.salaryMin, job.salaryMax), // Dùng helper
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget cho từng tag
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  // Helper để đổi màu card (logic không đổi, chỉ đổi tham số)
  Color _getCardColor(String companyName) {
    if (companyName.toLowerCase().contains('netflix')) {
      return const Color(0xFFFFF0F0);
    }
    if (companyName.toLowerCase().contains('microsoft')) {
      return const Color(0xFFF0F7FF);
    }
    if (companyName.toLowerCase().contains('figma')) {
      return const Color(0xFFF0F3FF);
    }
    return Colors.grey.shade50;
  }

  // Helper để đổi màu tag (logic không đổi, chỉ đổi tham số)
  Color _getTagColor(String companyName) {
    if (companyName.toLowerCase().contains('netflix')) {
      return const Color(0xFF14A800); // Màu xanh lá
    }
    if (companyName.toLowerCase().contains('microsoft')) {
      return const Color(0xFF007BFF); // Màu xanh dương
    }
    if (companyName.toLowerCase().contains('figma')) {
      return const Color(0xFF14A800); // Màu xanh lá
    }
    return Colors.teal;
  }
}