import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CvPreviewScreen extends StatelessWidget {
  final String? localPath;
  final String? fileUrl;

  const CvPreviewScreen({Key? key, this.localPath, this.fileUrl}) : super(key: key);

  Future<void> _downloadFile(BuildContext context) async {
    // Logic lưu file từ local cache (temp) ra thư mục Download của điện thoại
    if (localPath == null) return;

    var status = await Permission.storage.request();
    if (status.isGranted) {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (!await downloadDir.exists()) await downloadDir.create();

      final sourceFile = File(localPath!);
      final newPath = "${downloadDir.path}/CV_Generated_${DateTime.now().millisecondsSinceEpoch}.pdf";
      await sourceFile.copy(newPath);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã lưu vào thư mục Download!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cần cấp quyền để tải file.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lưu ý: Nếu dùng fileUrl (online), cần download về temp trước khi đưa vào PDFView
    // Ở code này giả định fileUrl đã được xử lý hoặc ưu tiên localPath cho tính năng Generate
    return Scaffold(
      appBar: AppBar(
        title: Text("Xem trước CV"),
        actions: [
          if (localPath != null)
            IconButton(icon: Icon(Icons.download), onPressed: () => _downloadFile(context))
        ],
      ),
      body: localPath != null
          ? PDFView(filePath: localPath!)
          : Center(child: Text("Đang tải hoặc không có file...")), // Cần xử lý logic tải từ URL nếu cần
    );
  }
}