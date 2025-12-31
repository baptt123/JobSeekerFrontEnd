import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CvPreviewScreen extends StatelessWidget {
  final String? url;           // Dùng cho CV đã lưu (URL Cloudinary)
  final Uint8List? fileData;   // Dùng cho CV vừa tạo (Raw bytes)
  final String title;

  const CvPreviewScreen({Key? key, this.url, this.fileData, this.title = "Xem CV"}) : super(key: key);

  Future<void> _download(BuildContext context) async {
    if (fileData == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Chức năng tải file từ URL đang cập nhật")));
      return;
    }
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/cv_gen_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(fileData!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã lưu: ${file.path}")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi lưu file: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(icon: Icon(Icons.download), onPressed: () => _download(context))
        ],
      ),
      body: fileData != null
          ? SfPdfViewer.memory(fileData!)
          : (url != null ? SfPdfViewer.network(url!) : Center(child: Text("Không có dữ liệu"))),
    );
  }
}