import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/company_detail_view_model.dart';
import 'package:job_seeker_frontend/models/job-entity.dart';
import 'package:job_seeker_frontend/views/login/user/job_detail_screen.dart';

// --- MÀU CHỦ ĐẠO ---
const Color kPrimaryColor = Color(0xFF6C63FF);

class CompanyDetailScreen extends StatelessWidget {
  final int companyId;
  final String companyName;

  const CompanyDetailScreen({
    Key? key,
    required this.companyId,
    required this.companyName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Xác định chế độ Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Định nghĩa bảng màu động dựa trên Theme
    final Color bgColor = isDark ? const Color(0xFF14131F) : const Color(0xFFF8F9FE);
    final Color cardColor = isDark ? const Color(0xFF1F1E2C) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : Colors.black87;
    final Color textSecondary = isDark ? Colors.white54 : Colors.black54;
    final Color borderColor = isDark ? Colors.white10 : Colors.grey.shade200;

    return ChangeNotifierProvider(
      create: (_) => CompanyDetailViewModel()..fetchCompanyData(companyId),
      child: Scaffold(
        backgroundColor: bgColor,
        // App Bar
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            companyName,
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.more_horiz, color: textSecondary, size: 24),
              onPressed: () {},
            )
          ],
        ),

        body: Consumer<CompanyDetailViewModel>(
          builder: (context, vm, _) {
            // Loading
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
            }

            // Error
            if (vm.errorMessage != null) {
              return Center(
                child: Text(
                  vm.errorMessage!,
                  style: TextStyle(color: textSecondary),
                ),
              );
            }

            // Success
            final company = vm.company;
            final jobs = vm.jobs;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. Header Thông tin công ty (Đã chỉnh màu tím)
                  _buildCompanyHeader(company),

                  const SizedBox(height: 30),

                  Text(
                    "Vị trí đang tuyển",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
                  ),
                  const SizedBox(height: 16),

                  // C. Danh sách công việc
                  if (jobs.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text("Công ty này chưa đăng tuyển dụng nào.", style: TextStyle(color: textSecondary)),
                      ),
                    )
                  else
                    ...jobs.map((job) => _buildJobCard(context, job, cardColor, textPrimary, textSecondary, borderColor)).toList(),

                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // [UPDATED] Widget Header: Chuyển background sang màu tím (kPrimaryColor) và chữ sang màu trắng
  Widget _buildCompanyHeader(dynamic company) {
    if (company == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryColor, // <--- Đổi nền thành màu tím
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: kPrimaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          // Logo container (Giữ nền trắng để logo hiển thị rõ)
          Container(
            width: 90,
            height: 90,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (company.logoUrl != null && company.logoUrl.startsWith('http'))
                  ? Image.network(company.logoUrl!, fit: BoxFit.contain)
                  : const Icon(Icons.business, size: 40, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),

          // Tên công ty (Màu trắng)
          Text(
            company.name ?? "Company Name",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Địa chỉ (Màu trắng nhạt)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  company.address ?? "Chưa cập nhật địa chỉ",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Website (Màu trắng đậm)
          if (company.website != null && company.website!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Text(
                  company.website!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget Job Card (Dynamic Theme) - Giữ nguyên logic hiển thị theo theme sáng/tối
  Widget _buildJobCard(BuildContext context, JobEntity job, Color cardColor, Color textPrimary,
      Color textSecondary, Color borderColor) {
    final bool isExpired = job.deadline != null && job.deadline!.isBefore(DateTime.now());
    final bool isActive = !isExpired;

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => JobDetailScreen(jobTitle: job.title)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.jobType ?? "Full-time",
                        style: const TextStyle(
                            color: kPrimaryColor, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                if (!isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                    const Text("Closed", style: TextStyle(color: Colors.red, fontSize: 12)),
                  )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  job.salaryMin != null
                      ? "\$${(job.salaryMin! / 1000).toInt()}k+"
                      : "Thỏa thuận",
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 16, color: textSecondary),
                const SizedBox(width: 4),
                Text(
                  job.deadline != null
                      ? "${job.deadline!.day}/${job.deadline!.month}"
                      : "N/A",
                  style: TextStyle(color: textSecondary, fontSize: 12),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}