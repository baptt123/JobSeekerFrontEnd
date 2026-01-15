import 'dart:io';
import 'dart:typed_data'; // Để xử lý Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart'; // Thư viện in ấn
import 'package:pdf/pdf.dart'; // [QUAN TRỌNG] Thêm dòng này để sửa lỗi PdfPageFormat

class CvPreviewScreen extends StatefulWidget {
  // Nhận path (local) hoặc url (online)
  final String localPath;

  const CvPreviewScreen({Key? key, required this.localPath}) : super(key: key);

  @override
  _CvPreviewScreenState createState() => _CvPreviewScreenState();
}

class _CvPreviewScreenState extends State<CvPreviewScreen> {
  String? localFilePath;
  int? pages = 0;
  bool isReady = false;
  String errorMessage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _processInputPath();
  }

  // Hàm xử lý đầu vào: Nếu là URL thì tải về, nếu là Path thì dùng luôn
  Future<void> _processInputPath() async {
    final path = widget.localPath;
    if (path.startsWith('http')) {
      // Xử lý hiển thị CV từ Cloudinary URL
      try {
        final downloadedFile = await _downloadFile(path);
        setState(() {
          localFilePath = downloadedFile;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          errorMessage = "Không thể tải CV từ Server: $e";
          isLoading = false;
        });
      }
    } else {
      // Đã là file local
      setState(() {
        localFilePath = path;
        isLoading = false;
      });
    }
  }

  Future<String> _downloadFile(String url) async {
    final dio = Dio();
    final dir = await getApplicationDocumentsDirectory();
    // Tạo tên file ngẫu nhiên hoặc từ URL để tránh trùng
    final fileName = url.split('/').last.split('?').first;
    final savePath = '${dir.path}/$fileName';

    await dio.download(url, savePath);
    return savePath;
  }

  // Hàm Share cũ (cho nút trên AppBar)
  void _shareFile() {
    if (localFilePath != null) {
      Share.shareXFiles(
        [XFile(localFilePath!)],
        text: 'CV của tôi (Tạo bởi TechConnect)',
      );
    }
  }

  // [MỚI] Hàm xử lý Tải về / In ấn thông qua thư viện Printing
  Future<void> _printCv() async {
    if (localFilePath == null) return;

    try {
      // Đọc file local thành bytes
      final file = File(localFilePath!);
      final Uint8List bytes = await file.readAsBytes();

      // Gọi giao diện in của hệ thống (cho phép lưu PDF hoặc In)
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'TechConnect_CV.pdf', // Tên file mặc định khi lưu
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi mở trình in ấn: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xem trước CV"),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (localFilePath != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareFile,
              tooltip: "Chia sẻ",
            )
        ],
      ),
      body: Stack(
        children: <Widget>[
          if (isLoading)
            const Center(child: CircularProgressIndicator()),

          if (!isLoading && errorMessage.isNotEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            )),

          if (!isLoading && localFilePath != null)
            PDFView(
              filePath: localFilePath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: false,
              onRender: (_pages) {
                setState(() {
                  pages = _pages;
                  isReady = true;
                });
              },
              onError: (error) {
                setState(() {
                  errorMessage = "Lỗi render PDF: $error";
                });
              },
              onPageError: (page, error) {
                setState(() {
                  errorMessage = '$page: ${error.toString()}';
                });
              },
            ),
        ],
      ),
      floatingActionButton: (!isLoading && localFilePath != null) ? FloatingActionButton.extended(
        onPressed: _printCv,
        icon: const Icon(Icons.print),
        label: const Text("Tải về / In CV"),
        backgroundColor: Colors.green,
      ) : null,
    );
  }
}