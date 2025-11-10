//
// 📄 [TẠO MỚI] baptt123/jobseekerfrontend/JobSeekerFrontEnd-develop/lib/views/login/user/cv_template_selection_screen.dart
//
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/views/login/user/cv_generation_view_screen.dart'; // Màn hình nhập liệu

class CvTemplateSelectionScreen extends StatelessWidget {
  const CvTemplateSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn Mẫu CV'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn một mẫu CV để bắt đầu',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildTemplateCard(
                    context,
                    'Template 1 - Hiện đại',
                    'assets/icon/cv_template_1.png', // Bạn cần thêm ảnh này vào assets
                    'template1',
                  ),
                  SizedBox(height: 16),
                  _buildTemplateCard(
                    context,
                    'Template 2 - Cổ điển 2 cột',
                    'assets/icon/cv_template_2.png', // Bạn cần thêm ảnh này vào assets
                    'template2',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, String title, String imagePath, String templateId) {
    return InkWell(
      onTap: () {
        // Chuyển sang màn hình Nhập Liệu (cv_generation_view_screen)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CvGenerationViewScreen(templateId: templateId),
          ),
        );
      },
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dùng ảnh bạn cung cấp
            // Hãy đảm bảo bạn đã thêm 2 file ảnh vào 'assets/icon/'
            // và khai báo trong pubspec.yaml
            Image.asset(
              imagePath,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Hiển thị nếu không tìm thấy ảnh
                return Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: Center(child: Text('Không tìm thấy ảnh\n$imagePath', textAlign: TextAlign.center)),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}