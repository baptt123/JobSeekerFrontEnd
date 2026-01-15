import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../services/cv_service.dart';
import '../../../utils/app_colors.dart'; // Import AppColors
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
          const SnackBar(
            content: Text("Vui lòng nhập mô tả bản thân!"),
            backgroundColor: Colors.redAccent,
          )
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<int> pdfBytes = await _cvService.generateCVAI(prompt);
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/cv_ai_gen_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes, flush: true);

      if (!mounted) return;

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
            backgroundColor: Theme.of(context).cardColor,
            title: const Text("Rất tiếc 😓"),
            content: Text("Có lỗi xảy ra: ${e.toString().replaceAll('Exception:', '')}"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Đóng")
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
    // Xác định chế độ tối/sáng
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Màu chữ tiêu đề dựa trên chế độ
    final titleColor = isDark ? Colors.white : AppColors.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        title: const Text("Tạo CV AI Thông Minh", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary, // [UPDATE] Màu Tím
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Icon(Icons.auto_awesome, size: 60, color: AppColors.accent), // [UPDATE] Màu Tím nhạt/Accent
                ),
                const SizedBox(height: 15),
                Text(
                  "Bạn muốn CV thế nào?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: titleColor),
                ),
                const SizedBox(height: 8),
                Text(
                  "Mô tả kinh nghiệm, kỹ năng và mong muốn của bạn.\nGemini sẽ thiết kế CV chuyên nghiệp ngay lập tức.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 25),

                // Input Card
                Card(
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.2), // [UPDATE] Shadow tím
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: isDark ? AppColors.cardDark : Colors.white, // Màu Card theo theme
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextField(
                      controller: _promptController,
                      maxLines: 8,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(15),
                        hintText: "Ví dụ: Tôi tên Nam, Developer Flutter 2 năm kinh nghiệm. Kỹ năng: Dart, Git, Firebase. Đã làm app TMĐT...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generate,
                    icon: const Icon(Icons.star),
                    label: const Text("Tạo CV Ngay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // [UPDATE] Màu Tím
                      foregroundColor: Colors.white,      // [UPDATE] Chữ trắng để dễ đọc
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
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.accent), // [UPDATE] Màu loading tím
                    const SizedBox(height: 20),
                    const Text(
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