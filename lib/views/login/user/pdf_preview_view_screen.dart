import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart'; // Gói xem PDF
import 'package:file_saver/file_saver.dart'; // Gói lưu file
import 'package:permission_handler/permission_handler.dart';

class PdfPreviewView extends StatefulWidget {
  final Uint8List pdfData;
  const PdfPreviewView({super.key, required this.pdfData});

  @override
  State<PdfPreviewView> createState() => _PdfPreviewViewState();
}

class _PdfPreviewViewState extends State<PdfPreviewView> {
  late final PdfController _pdfController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Nạp dữ liệu PDF (bytes) vào controller
    _pdfController = PdfController(
      document: PdfDocument.openData(widget.pdfData),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  // Hàm xử lý logic tải về
  Future<void> _onDownloadPressed() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Xin quyền (rất quan trọng trên Android 10+)
      // Trên iOS, quyền này thường được ngầm định khi lưu vào thư mục Files
      var status = await Permission.storage.request();
      if (status.isDenied) {
        status = await Permission.manageExternalStorage.request();
      }

      if (!status.isGranted) {
        throw Exception('Không được cấp quyền lưu file.');
      }

      // 2. Dùng FileSaver để lưu file
      final String fileName = 'cv_cua_ban_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: widget.pdfData,
        mimeType: MimeType.pdf, // Backend của bạn gửi 'application/pdf'
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã lưu CV thành công: $fileName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu file: $e')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem Trước CV'),
        actions: [
          // Nút Tải Về
          _isSaving
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          )
              : IconButton(
            icon: const Icon(Icons.download),
            onPressed: _onDownloadPressed,
            tooltip: 'Tải CV về máy',
          ),
        ],
      ),
      // Hiển thị nội dung PDF
      body: PdfView(
        controller: _pdfController,
      ),
    );
  }
}