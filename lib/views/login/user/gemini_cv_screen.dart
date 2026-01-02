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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Vui lòng nhập mô tả bản thân!"),
            backgroundColor: Colors.redAccent,
          )
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Gọi API lấy file PDF dạng bytes
      List<int> pdfBytes = await _cvService.generateCVAI(prompt);

      // 2. Lưu thành file tạm trên thiết bị
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/cv_ai_gen_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes, flush: true);

      if (!mounted) return;

      // 3. Chuyển sang màn hình xem trước (Preview)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CvPreviewScreen(localPath: file.path),
        ),
      );

    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Rất tiếc 😓"),
            content: Text("Có lỗi xảy ra: ${e.toString().replaceAll('Exception:', '')}"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Đóng")
              )
            ],
          )
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Tạo CV AI Thông Minh"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Icon
                Center(
                  child: Icon(Icons.auto_awesome, size: 60, color: Colors.amber),
                ),
                SizedBox(height: 15),
                Text(
                  "Bạn muốn CV thế nào?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                ),
                SizedBox(height: 8),
                Text(
                  "Mô tả kinh nghiệm, kỹ năng và mong muốn của bạn.\nGemini sẽ thiết kế CV chuyên nghiệp ngay lập tức.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 25),

                // Input Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextField(
                      controller: _promptController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(15),
                        hintText: "Ví dụ: Tôi tên Nam, Developer Flutter 2 năm kinh nghiệm. Kỹ năng: Dart, Git, Firebase. Đã làm app TMĐT...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generate,
                    icon: Icon(Icons.star),
                    label: Text("Tạo CV Ngay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                )
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      "Đang phân tích & thiết kế...",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}