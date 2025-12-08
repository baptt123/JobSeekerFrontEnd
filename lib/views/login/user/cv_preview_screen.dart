// lib/views/login/user/cv_preview_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart'; // Thư viện hỗ trợ Share/Print PDF
import 'package:job_seeker_frontend/dto/create_cv_dto.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class CvPreviewScreen extends StatelessWidget {
  final Uint8List? pdfData; // Dữ liệu PDF (bytes) nhận từ API
  final String title;

  // Các trường này có thể giữ lại để hiển thị info, nhưng không dùng để gọi API save nữa
  final String? templateId;
  final CreateCvDto? cvData;

  const CvPreviewScreen({
    super.key,
    this.pdfData,
    this.title = "Xem trước CV",
    this.templateId,
    this.cvData,
    // Bỏ isSaveMode vì bây giờ luôn cho phép tải về
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          // Nút Download / Save to Device
          if (pdfData != null)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: "Tải về thiết bị",
              onPressed: () => _handleDownloadToDevice(context),
            ),
        ],
      ),
      body: pdfData == null
          ? const Center(child: Text("Không có dữ liệu PDF"))
          : PdfPreview(
        build: (format) => pdfData!, // Hiển thị file PDF từ bytes
        useActions: false, // Tắt các action mặc định để dùng nút tùy chỉnh của mình
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        scrollViewDecoration: BoxDecoration(
          color: Colors.grey[200],
        ),
      ),
    );
  }

  /// Hàm xử lý lưu file về thiết bị (Client-side only)
  Future<void> _handleDownloadToDevice(BuildContext context) async {
    if (pdfData == null) return;

    try {
      // Sử dụng tính năng Share của gói printing.
      // Trên Mobile (Android/iOS), nó sẽ mở hộp thoại Share hệ thống.
      // Người dùng chọn "Save to Files" (iOS) hoặc trình quản lý file (Android) để lưu.
      await Printing.sharePdf(
        bytes: pdfData!,
        filename: 'my_cv_job_seeker.pdf',
      );

      // Nếu muốn in trực tiếp:
      // await Printing.layoutPdf(onLayout: (_) => pdfData!);

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi khi tải file: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}