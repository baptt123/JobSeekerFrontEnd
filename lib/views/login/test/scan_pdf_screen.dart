import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/scan_pdf_view_model.dart';
class ScanPdfScreen extends StatelessWidget {
  const ScanPdfScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi từ ViewModel
    final viewModel = context.watch<ScanPdfViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trích xuất nội dung PDF"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. Khung Upload File (Đã làm đẹp) ---
            _buildFileUploadButton(context, viewModel),

            const SizedBox(height: 24),

            // --- 2. Khung Nội dung (Đã làm đẹp) ---
            Text(
              "Nội dung trích xuất:",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildExtractedContentBox(context, viewModel),
          ],
        ),
      ),
    );
  }

  /// Widget cho nút/khung upload file
  Widget _buildFileUploadButton(BuildContext context, ScanPdfViewModel viewModel) {
    return GestureDetector(
      // Chỉ cho phép nhấn khi không loading
      onTap: viewModel.isLoading ? null : viewModel.pickAndScanPdf,
      child: Container( // <-- Bỏ DottedBorder, chỉ giữ lại Container
        height: 150,
        decoration: BoxDecoration(
          color: viewModel.isLoading ? Colors.grey[200] : Colors.greenAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          // 👇 Thay thế DottedBorder bằng Border.all (viền nét liền)
          border: Border.all(
            color: viewModel.isLoading ? Colors.grey : Colors.greenAccent.withOpacity(0.8),
            width: 2,
          ),
        ),
        child: Center(
          child: viewModel.isLoading && viewModel.fileName.isNotEmpty
              ? Column( // Hiển thị loading và tên file
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                "Đang xử lý: ${viewModel.fileName}",
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          )
              : Column( // Hiển thị icon và text
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_file_rounded,
                size: 50,
                color: Colors.greenAccent.withOpacity(0.8),
              ),
              const SizedBox(height: 8),
              Text(
                "Nhấn để chọn file PDF",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.greenAccent.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget cho khung hiển thị nội dung
  Widget _buildExtractedContentBox(BuildContext context, ScanPdfViewModel viewModel) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: viewModel.isLoading && viewModel.fileName.isEmpty
            ? const Center( // Trạng thái loading (khi chưa có tên file)
          child: CircularProgressIndicator(),
        )
            : viewModel.extractedText.isEmpty
            ? Center( // Trạng thái ban đầu
          child: Text(
            "Nội dung được trích xuất sẽ xuất hiện ở đây...",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
        )
            : SingleChildScrollView( // Hiển thị nội dung
          child: SelectableText( // Dùng SelectableText để cho phép copy
            viewModel.extractedText,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}