// lib/views/login/user/scan_pdf_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/scan_pdf_view_model.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class ScanPdfScreen extends StatelessWidget {
  const ScanPdfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng ChangeNotifierProvider để tạo ViewModel
    return ChangeNotifierProvider(
      create: (_) => ScanPdfViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Quét CV thông minh', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          leading: const BackButton(color: Colors.black87),
        ),
        body: Consumer<ScanPdfViewModel>(
          builder: (context, vm, _) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Tải lên CV của bạn",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Hệ thống sẽ tự động phân tích kỹ năng, lưu hồ sơ và gợi ý việc làm phù hợp.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Khu vực Upload (Drag & Drop UI)
                  GestureDetector(
                    onTap: vm.isLoading ? null : () => vm.pickPdf(),
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: kPrimaryColor.withOpacity(0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (vm.isLoading) ...[
                            const CircularProgressIndicator(color: kPrimaryColor),
                            const SizedBox(height: 16),
                            const Text("Đang phân tích...", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                vm.fileName != null ? Icons.picture_as_pdf : Icons.cloud_upload_rounded,
                                size: 50,
                                color: kPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              vm.fileName ?? 'Chạm để chọn file PDF',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: vm.fileName != null ? Colors.black87 : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (vm.fileName == null)
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text("Hỗ trợ định dạng .PDF (Max 5MB)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ),
                          ]
                        ],
                      ),
                    ),
                  ),

                  // Nút Xóa file (nếu đã chọn)
                  if (vm.fileName != null && !vm.isLoading)
                    TextButton.icon(
                      onPressed: vm.clearFile,
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text("Chọn file khác", style: TextStyle(color: Colors.red)),
                    ),

                  const Spacer(),

                  // Button Hành động
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (vm.fileName != null && !vm.isLoading)
                          ? () => vm.uploadAndScan(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                        shadowColor: kPrimaryColor.withOpacity(0.4),
                      ),
                      child: const Text(
                        "Bắt đầu phân tích",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}