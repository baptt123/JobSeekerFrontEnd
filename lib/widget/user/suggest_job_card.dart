// lib/views/widgets/suggested_job_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/job-entity.dart'; // Import thư viện intl

// Giả định bạn cũng có file company_entity.dart trong models
// import '../../models/company_entity.dart';

class SuggestedJobCard extends StatelessWidget {
  // 1. Đổi model thành JobEntity
  final JobEntity job;
  const SuggestedJobCard({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format tiền tệ
    final currencyFormatter =
    NumberFormat.simpleCurrency(locale: 'en_US', decimalDigits: 0);

    // Sử dụng salary_max hoặc salary_min
    final salary = currencyFormatter.format(job.salaryMax ?? job.salaryMin ?? 0);

    // 2. Lấy tên công ty từ object lồng nhau
    final companyName = job.company?.name ?? 'N/A';

    return Container(
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
              // 4. Cập nhật placeholder logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                // Hiển thị chữ cái đầu tiên của tên công ty
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
                // LƯU Ý: Nếu CompanyEntity của bạn có 'logoUrl',
                // bạn có thể dùng Image.network(job.company!.logoUrl) ở đây
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
                      companyName, // Dùng biến đã lấy ở trên
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              // Icon save
              Icon(Icons.bookmark_border_outlined, color: Colors.grey.shade600),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Cập nhật phần Tags
          // Chỉ hiển thị job.jobType nếu nó tồn tại
          if (job.jobType != null && job.jobType!.isNotEmpty)
            _buildTag(job.jobType!)
          else
            const SizedBox(height: 8), // Giữ khoảng cách nếu không có tag

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 5. Xử lý location có thể null
              Text(
                job.location ?? 'N/A',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              Text(
                '$salary/Month', // Thêm /Month
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F2), // Màu teal rất nhạt
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Color(0xFF00695C), // Màu teal đậm
            fontWeight: FontWeight.w500),
      ),
    );
  }
}