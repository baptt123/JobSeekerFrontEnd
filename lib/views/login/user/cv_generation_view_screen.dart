import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/views/login/user/pdf_preview_view_screen.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/cv_generation_view_model.dart';

class CvGenerationViewScreen extends StatefulWidget {
  const CvGenerationViewScreen({super.key});

  @override
  State<CvGenerationViewScreen> createState() => _CvGenerationViewState();
}

class _CvGenerationViewState extends State<CvGenerationViewScreen> {
  final _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _onGeneratePressed() {
    final prompt = _promptController.text;
    if (prompt.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập mô tả CV của bạn'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }
    context.read<CvGenerationViewModel>().generateCv(prompt);
  }

  @override
  Widget build(BuildContext context) {
    // --- Chọn màu xanh lá chủ đạo ---
    // Bạn có thể đổi thành Colors.green.shade600, Color(0xFF4CAF50), v.v.
    final Color primaryColor = Colors.teal.shade600;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo CV với AI'),
        // --- 1. AppBar với màu xanh lá ---
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        // --- 2. Nền Gradient cho sặc sỡ ---
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor.withOpacity(0.05), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // --- 3. SingleChildScrollView để tránh lỗi keyboard ---
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0), // Tăng padding
            child: Column(
              children: [
                // --- 4. Icon trang trí ---
                Icon(
                  Icons.auto_stories_outlined,
                  size: 80,
                  color: primaryColor.withOpacity(0.8),
                ),
                const SizedBox(height: 10),
                Text(
                  'Mô tả CV mơ ước của bạn',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // --- 5. Ô nhập liệu được style lại ---
                TextField(
                  controller: _promptController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Mô tả về bản thân, kinh nghiệm, kỹ năng... '
                        '(Ví dụ: "làm cv cho lập trình viên backend nodejs 2 năm kinh nghiệm"...)',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none, // Bỏ viền mặc định
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 6. Nút bấm và trạng thái
                Consumer<CvGenerationViewModel>(
                  builder: (context, viewModel, child) {
                    // Xử lý điều hướng (giữ nguyên)
                    if (viewModel.state == CvGenerationState.success &&
                        viewModel.pdfData != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfPreviewView(
                              pdfData: viewModel.pdfData!,
                            ),
                          ),
                        ).then((_) {
                          viewModel.resetState();
                        });
                      });
                    }

                    // HIỂN THỊ LOADING (Style lại)
                    if (viewModel.state == CvGenerationState.loading) {
                      return Column(
                        children: [
                          CircularProgressIndicator(
                            // --- 7. Loading màu xanh lá ---
                            valueColor:
                            AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'AI đang tạo CV, vui lòng chờ...',
                            style: TextStyle(
                              fontSize: 16,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }

                    // HIỂN THỊ NÚT BẤM (Style lại)
                    return ElevatedButton.icon(
                      onPressed: _onGeneratePressed,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Tạo CV Ngay'),
                      // --- 8. Style nút bấm cho đẹp ---
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor, // Màu nền xanh
                        foregroundColor: Colors.white, // Màu chữ/icon trắng
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 18),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(30), // Bo tròn
                        ),
                        elevation: 5, // Đổ bóng
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 9. Hiển thị lỗi (Style lại)
                Consumer<CvGenerationViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.state == CvGenerationState.error &&
                        viewModel.errorMessage != null) {
                      // --- 10. Hộp thông báo lỗi rõ ràng ---
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade700),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                viewModel.errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}