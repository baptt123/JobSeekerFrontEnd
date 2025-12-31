import 'package:flutter/material.dart';
import 'cv_generation_view_screen.dart'; // Import màn hình điền form

class CvTemplateSelectionScreen extends StatelessWidget {
  // Danh sách giả định các template (có thể load từ API nếu cần)
  final List<Map<String, dynamic>> templates = [
    {'id': 1, 'name': 'Mẫu Chuyên nghiệp', 'image': 'assets/icon/cv_template_1.png'},
    {'id': 2, 'name': 'Mẫu Sáng tạo', 'image': 'assets/icon/cv_template_2.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chọn Mẫu CV")),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: templates.length,
        itemBuilder: (ctx, i) {
          final t = templates[i];
          return GestureDetector(
            onTap: () {
              // Chuyển sang màn hình điền thông tin cho template này
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CvGenerationViewScreen(templateId: t['id']),
                ),
              );
            },
            child: Card(
              elevation: 4,
              child: Column(
                children: [
                  Expanded(
                    // Hiển thị ảnh mẫu (cần đảm bảo assets có ảnh)
                    child: Image.asset(t['image'], fit: BoxFit.cover, errorBuilder: (_,__,___) => Icon(Icons.image, size: 50)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(t['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}