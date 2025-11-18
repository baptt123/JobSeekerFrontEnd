import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/scan_pdf_view_model.dart';

class ScanPdfScreen extends StatelessWidget {
  const ScanPdfScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lắng nghe ViewModel
    final viewModel = context.watch<ScanPdfViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trích xuất CV PDF"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. Khung Upload File ---
            _buildFileUploadButton(context, viewModel),

            const SizedBox(height: 24),

            // --- 2. Tiêu đề ---
            Text(
              "Kết quả phân tích:",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // --- 3. Khung Nội dung ---
            _buildExtractedContentBox(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadButton(BuildContext context, ScanPdfViewModel viewModel) {
    return GestureDetector(
      // Truyền context vào hàm scan để lấy User ID (nếu cần)
      onTap: viewModel.isLoading
          ? null
          : () => viewModel.pickAndScanPdf(context),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: viewModel.isLoading
              ? Colors.grey[100]
              : Colors.greenAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: viewModel.isLoading
                ? Colors.grey
                : Colors.green,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: viewModel.isLoading && viewModel.fileName.isNotEmpty
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.green),
              const SizedBox(height: 16),
              Text(
                "Đang xử lý: ${viewModel.fileName}...",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: Colors.green[700],
              ),
              const SizedBox(height: 12),
              Text(
                "Nhấn để chọn file CV (PDF)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtractedContentBox(BuildContext context, ScanPdfViewModel viewModel) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: viewModel.isLoading && viewModel.fileName.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : viewModel.extractedText.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description_outlined,
                  size: 40, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                "Nội dung CV sẽ hiển thị tại đây",
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SelectableText(
            viewModel.extractedText,
            style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}