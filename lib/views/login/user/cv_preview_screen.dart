import 'package:flutter/material.dart';

class CvPreviewScreen extends StatelessWidget {
  const CvPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem trước CV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Logic tải xuống PDF
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang tải xuống CV...')),
              );
            },
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 7, offset: const Offset(0, 3)),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, size: 80, color: Colors.red),
              SizedBox(height: 16),
              Text('Hiển thị nội dung PDF ở đây', style: TextStyle(fontSize: 16)),
              // Trong thực tế, bạn sẽ dùng package như flutter_pdfview để hiển thị file
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Logic ứng tuyển nhanh bằng CV này
        },
        label: const Text('Dùng CV này'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}