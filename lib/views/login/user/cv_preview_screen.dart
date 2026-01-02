import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

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
      // [YÊU CẦU 3] Xử lý hiển thị CV từ Cloudinary URL
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

  void _downloadOrShare() {
    if (localFilePath != null) {
      Share.shareXFiles(
        [XFile(localFilePath!)],
        text: 'CV của tôi (Tạo bởi TechConnect)',
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
              onPressed: _downloadOrShare,
              tooltip: "Tải về hoặc Chia sẻ",
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
        onPressed: _downloadOrShare,
        icon: const Icon(Icons.download),
        label: const Text("Tải CV về máy"),
        backgroundColor: Colors.green,
      ) : null,
    );
  }
}