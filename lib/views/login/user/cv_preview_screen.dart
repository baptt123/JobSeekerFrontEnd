//
// 📄 [TẠO MỚI] baptt123/jobseekerfrontend/JobSeekerFrontEnd-develop/lib/views/login/user/cv_preview_screen.dart
//
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/dto/create_cv_dto.dart';
import 'package:job_seeker_frontend/view_models/user/cv_generation_view_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:path_provider/path_provider.dart'; // Dùng để lưu file
// import 'package:flutter_downloader/flutter_downloader.dart'; // Dùng để tải về (nếu là PDF)
// import 'dart:io';

class CvPreviewScreen extends StatefulWidget {
  final String htmlContent;
  final CreateCvDto cvData;
  final String templateId;

  const CvPreviewScreen({
    Key? key,
    required this.htmlContent,
    required this.cvData,
    required this.templateId,
  }) : super(key: key);

  @override
  State<CvPreviewScreen> createState() => _CvPreviewScreenState();
}

class _CvPreviewScreenState extends State<CvPreviewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.dataFromString(
        widget.htmlContent,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ));
  }

  void _onDownload() async {
    // Hiện tại, chức năng này chỉ là gọi API download (vẫn trả về HTML)
    // Khi backend nâng cấp lên PDF, logic ở đây sẽ cần thay đổi
    // (ví dụ: dùng flutter_downloader hoặc path_provider để lưu file)

    final viewModel = Provider.of<CvGenerationViewModel>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đang chuẩn bị tải về... (Hiện tại sẽ là file .html)')),
    );

    try {
      final response = await viewModel.downloadCv(widget.templateId, widget.cvData);

      if (response.statusCode == 200) {
        // Đây là logic xử lý khi backend trả về file PDF thực sự
        final bytes = response.data;
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/my_cv.pdf');
        await file.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã lưu vào: ${file.path}')),
        );

        // Tạm thời chỉ thông báo
        print('Header tải về: ${response.headers['content-disposition']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã gọi API Tải về thành công!')),
        );
      } else {
        throw Exception('Lỗi khi tải file: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xem trước CV'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _onDownload,
            tooltip: 'Tải về',
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}