import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../services/cv_service.dart';
import 'cv_preview_screen.dart';

class GeminiCvScreen extends StatefulWidget {
  @override
  _GeminiCvScreenState createState() => _GeminiCvScreenState();
}

class _GeminiCvScreenState extends State<GeminiCvScreen> {
  final TextEditingController _promptController = TextEditingController();
  final CVService _cvService = CVService();
  bool _isLoading = false;

  void _generate() async {
    String prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vui lòng nhập mô tả.")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      List<int> pdfBytes = await _cvService.generateCVAI(prompt);

      // Lưu file tạm để preview
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/cv_gen_ai.pdf');
      await file.writeAsBytes(pdfBytes, flush: true);

      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Thành công"),
            content: Text("CV đã được tạo bởi Gemini!"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng dialog
                    // Chuyển sang màn hình Preview
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CvPreviewScreen(localPath: file.path)));
                  },
                  child: Text("Xem & Tải xuống")
              )
            ],
          )
      );

    } catch (e) {
      showDialog(context: context, builder: (_) => AlertDialog(title: Text("Lỗi"), content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tạo CV với Gemini AI")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              maxLines: 5,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Mô tả bản thân: Tôi là Dev Flutter 2 năm kinh nghiệm, kỹ năng Dart, Git...",
                  labelText: "Nội dung CV"
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                onPressed: _generate,
                icon: Icon(Icons.auto_awesome),
                label: Text("Tạo CV Ngay")
            )
          ],
        ),
      ),
    );
  }
}