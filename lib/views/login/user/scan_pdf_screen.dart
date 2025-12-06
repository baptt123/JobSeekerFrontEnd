import 'package:flutter/material.dart';

class ScanPdfScreen extends StatefulWidget {
  const ScanPdfScreen({super.key});

  @override
  State<ScanPdfScreen> createState() => _ScanPdfScreenState();
}

class _ScanPdfScreenState extends State<ScanPdfScreen> {
  String? _fileName;
  bool _isUploading = false;

  void _pickFile() async {
    // Logic dùng file_picker để chọn file
    setState(() {
      _fileName = "my_cv_2025.pdf"; // Giả lập đã chọn file
    });
  }

  void _uploadFile() async {
    if (_fileName == null) return;
    setState(() => _isUploading = true);

    // Giả lập upload lên server
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isUploading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phân tích CV thành công!')),
      );
      // Navigate to result or fill data form
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét CV (PDF)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue.withOpacity(0.05),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    _fileName ?? 'Chạm để chọn file PDF',
                    style: TextStyle(
                        fontSize: 16,
                        color: _fileName != null ? Colors.black : Colors.grey
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
              ),
              child: const Text('Chọn File'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_fileName != null && !_isUploading) ? _uploadFile : null,
              child: _isUploading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Tải lên & Phân tích'),
            ),
          ],
        ),
      ),
    );
  }
}