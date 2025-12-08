import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/company_detail_view_model.dart';
import 'package:job_seeker_frontend/models/job-entity.dart';
import 'package:job_seeker_frontend/views/login/user/job_detail_screen.dart';

// --- BẢNG MÀU DARK MODE (Trích xuất từ thiết kế) ---
const Color kBgColor = Color(0xFF14131F);      // Màu nền chính (Tím than rất tối)
const Color kCardColor = Color(0xFF1F1E2C);    // Màu nền Card
const Color kAccentColor = Color(0xFF6C63FF);  // Màu chủ đạo (Tím sáng)
const Color kTextWhite = Colors.white;
const Color kTextGrey = Colors.white54;
const Color kGreenTagBg = Color(0xFF2E5C55);   // Nền tag Active
const Color kGreenText = Color(0xFF4ADE80);    // Chữ tag Active
const Color kRedTagBg = Color(0xFF5C2E2E);     // Nền tag Closed
const Color kRedText = Color(0xFFDE4A4A);      // Chữ tag Closed

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
    return ChangeNotifierProvider(
      // Khởi tạo ViewModel và gọi API fetch dữ liệu ngay khi màn hình được tạo
      create: (_) => CompanyDetailViewModel()..fetchCompanyData(companyId),
      child: Scaffold(
        backgroundColor: kBgColor,

        // --- APP BAR ---
        appBar: AppBar(
          backgroundColor: kBgColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: kTextWhite, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
              companyName,
              style: const TextStyle(color: kTextWhite, fontWeight: FontWeight.bold, fontSize: 18)
          ),
          centerTitle: true,
          actions: [
            // Nút "More" giả lập
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: kCardColor, shape: BoxShape.circle),
                child: const Icon(Icons.more_horiz, color: kTextWhite, size: 20),
              ),
              onPressed: () {},
            )
          ],
        ),

        // --- BODY ---
        body: Consumer<CompanyDetailViewModel>(
          builder: (context, vm, _) {
            // 1. Trạng thái Loading
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator(color: kAccentColor));
            }

            // 2. Trạng thái Lỗi (Mất mạng hoặc API lỗi)
            if (vm.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 64, color: kTextGrey),
                    const SizedBox(height: 16),
                    Text(
                      vm.errorMessage!,
                      style: const TextStyle(color: kTextGrey, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => vm.fetchCompanyData(companyId), // Thử lại
                      icon: const Icon(Icons.refresh),
                      label: const Text("Thử lại"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    )
                  ],
                ),
              );
            }

            // 3. Trạng thái Success (Hiển thị dữ liệu)
            final company = vm.company;
            final jobs = vm.jobs;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. Header Thông tin công ty
                  _buildCompanyHeader(company),

                  const SizedBox(height: 30),

                  // B. Thanh tìm kiếm (Giả lập giống ảnh)
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: kTextGrey),
                        SizedBox(width: 12),
                        Text(
                          "Tìm kiếm vị trí công việc...",
                          style: TextStyle(color: kTextGrey, fontSize: 14),
                        ),
                        Spacer(),
                        Icon(Icons.filter_list, color: kTextGrey),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // C. Danh sách công việc
                  if (jobs.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text("Công ty này chưa đăng tuyển dụng nào.", style: TextStyle(color: kTextGrey)),
                      ),
                    )
                  else
                    ...jobs.map((job) => _buildDarkJobCard(context, job)).toList(),

                  // Padding dưới cùng để không bị che bởi bottom nav
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),

        // --- BOTTOM NAVIGATION (Giả lập) ---
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // Widget Header: Logo, Tên, Web
  Widget _buildCompanyHeader(dynamic company) {
    if (company == null) return const SizedBox.shrink();
    return Center(
      child: Column(
        children: [
          Container(
            width: 90, height: 90,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: (company.logoUrl != null && company.logoUrl.startsWith('http'))
                  ? Image.network(company.logoUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.business, size: 40, color: kTextGrey),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            company.name ?? "Company Name",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTextWhite),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 16, color: kTextGrey),
              const SizedBox(width: 4),
              Text(
                company.address ?? "Chưa cập nhật địa chỉ",
                style: const TextStyle(color: kTextGrey, fontSize: 14),
              ),
            ],
          ),
          if (company.website != null && company.website!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                company.website!,
                style: const TextStyle(color: kAccentColor, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  // Widget Job Card (Dark Theme)
  Widget _buildDarkJobCard(BuildContext context, JobEntity job) {
    // Logic hiển thị trạng thái (Giả lập dựa trên deadline)
    final bool isExpired = job.deadline != null && job.deadline!.isBefore(DateTime.now());
    final bool isActive = !isExpired;

    return GestureDetector(
      onTap: () {
        // Điều hướng sang trang chi tiết Job
        Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => JobDetailScreen(jobTitle: job.title))
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng 1: Title + Status
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextWhite, height: 1.3),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        job.jobType ?? "Full-time",
                        style: const TextStyle(color: kTextGrey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Status Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? kGreenTagBg.withOpacity(0.2) : kRedTagBg.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: isActive ? kGreenText : kRedText),
                      const SizedBox(width: 6),
                      Text(
                        isActive ? "Active" : "Closed",
                        style: TextStyle(
                            color: isActive ? kGreenText : kRedText,
                            fontWeight: FontWeight.bold, fontSize: 11
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            // Hàng 2: Info (Applicants, Deadline)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconText(Icons.attach_money,
                    (job.salaryMin != null) ? "\$${(job.salaryMin!/1000).toInt()}k+" : "Thỏa thuận"
                ),
                _buildIconText(Icons.calendar_today_outlined,
                    job.deadline != null ? "Hạn: ${job.deadline!.day}/${job.deadline!.month}" : "Không hạn"
                ),
              ],
            ),

            const SizedBox(height: 20),
            Divider(color: Colors.white.withOpacity(0.1), height: 1),
            const SizedBox(height: 16),

            // Hàng 3: Action Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Xem chi tiết", style: TextStyle(color: isActive ? kGreenText : kTextGrey, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16, color: isActive ? kGreenText : kTextGrey),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: kTextGrey, size: 18),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: kTextWhite, fontSize: 13)),
      ],
    );
  }

  // Bottom Nav (Chỉ để trang trí cho giống ảnh mẫu)
  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: kBgColor,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MockNavItem(icon: Icons.dashboard_rounded, label: "Dashboard", isActive: true),
          _MockNavItem(icon: Icons.chat_bubble_outline_rounded, label: "Messages", isActive: false),
          _MockNavItem(icon: Icons.person_outline_rounded, label: "Profile", isActive: false),
        ],
      ),
    );
  }
}

class _MockNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _MockNavItem({required this.icon, required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? kGreenText : kTextGrey),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isActive ? kGreenText : kTextGrey, fontSize: 12)),
      ],
    );
  }
}