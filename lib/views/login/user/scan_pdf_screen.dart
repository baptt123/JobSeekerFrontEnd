import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/user/scan_pdf_view_model.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class ScanPdfScreen extends StatelessWidget {
  const ScanPdfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScanPdfViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Trích xuất Keyword từ CV"),
          backgroundColor: kPrimaryColor,
          elevation: 0,
        ),
        body: Consumer<ScanPdfViewModel>(
          builder: (ctx, viewModel, child) {
            // Lắng nghe sự kiện lỗi/thành công
            // Lưu ý: Trong thực tế nên dùng Listener hoặc Stream, nhưng dùng addPostFrameCallback tạm ổn
            if (viewModel.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showDialog(ctx, "Lỗi", viewModel.errorMessage!);
                // Cần hàm clearError trong ViewModel để tránh loop dialog
                // viewModel.clearError();
              });
            }

            if (viewModel.extractedKeywords != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showDialog(ctx, "Thành công", "Keywords tìm thấy: ${viewModel.extractedKeywords}");
                // viewModel.clearSuccess();
              });
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                    child: const Icon(Icons.upload_file, size: 60, color: kPrimaryColor),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Tải lên CV (PDF)",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Hệ thống sẽ sử dụng AI để phân tích và trích xuất các kỹ năng quan trọng từ CV của bạn.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 40),

                  if (viewModel.isLoading)
                    const CircularProgressIndicator(color: kPrimaryColor)
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => viewModel.pickAndUploadCv(),
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text("Chọn File PDF", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: TextStyle(color: title == "Lỗi" ? Colors.red : Colors.green)),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng"))
        ],
      ),
    );
  }
}