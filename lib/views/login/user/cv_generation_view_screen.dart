import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/views/login/user/pdf_preview_view_screen.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/cv_generation_view_model.dart';

class CvGenerationView extends StatefulWidget {
  const CvGenerationView({super.key});

  @override
  State<CvGenerationView> createState() => _CvGenerationViewState();
}

class _CvGenerationViewState extends State<CvGenerationView> {
  final _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nhấn nút
  void _onGeneratePressed() {
    final prompt = _promptController.text;
    if (prompt.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mô tả CV của bạn')),
      );
      return;
    }

    // Gọi ViewModel để bắt đầu tạo CV
    // `listen: false` vì chúng ta đang ở trong một hàm callback
    context.read<CvGenerationViewModel>().generateCv(prompt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo CV với AI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Ô nhập liệu
            TextField(
              controller: _promptController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Mô tả về bản thân, kinh nghiệm, kỹ năng... '
                    '(Ví dụ: "làm cv cho lập trình viên backend nodejs 2 năm kinh nghiệm"...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Nút bấm và trạng thái
            // 'Consumer' sẽ tự động "vẽ lại" phần này khi ViewModel thay đổi
            Consumer<CvGenerationViewModel>(
              builder: (context, viewModel, child) {
                // Xử lý điều hướng KHI TẠO CV XONG
                if (viewModel.state == CvGenerationState.success &&
                    viewModel.pdfData != null) {
                  // Dùng addPostFrameCallback để điều hướng an toàn
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfPreviewView(
                          pdfData: viewModel.pdfData!,
                        ),
                      ),
                    ).then((_) {
                      // Khi quay lại từ trang preview, reset state
                      viewModel.resetState();
                    });
                  });
                }

                // HIỂN THỊ NÚT BẤM HOẶC LOADING
                if (viewModel.state == CvGenerationState.loading) {
                  return const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('AI đang tạo CV, vui lòng chờ...'),
                    ],
                  );
                }

                return ElevatedButton.icon(
                  onPressed: _onGeneratePressed,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Tạo CV Ngay'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 3. Hiển thị lỗi (nếu có)
            Consumer<CvGenerationViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.state == CvGenerationState.error &&
                    viewModel.errorMessage != null) {
                  return Text(
                    viewModel.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  );
                }
                return const SizedBox.shrink(); // Không có lỗi, ẩn đi
              },
            ),
          ],
        ),
      ),
    );
  }
}