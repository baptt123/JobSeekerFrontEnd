// lib/views/login/user/cv_template_selection_screen.dart

import 'package:flutter/material.dart';
import 'cv_generation_view_screen.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class CvTemplateSelectionScreen extends StatelessWidget {
  const CvTemplateSelectionScreen({super.key});

  final List<Map<String, String>> templates = const [
    {'id': '1', 'name': 'Thanh lịch (Xám)', 'image': 'assets/icon/cv_template_1.png'},
    {'id': '2', 'name': 'Hiện đại (Xanh)', 'image': 'assets/icon/cv_template_2.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Chọn mẫu CV', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return Card(
            elevation: 4,
            shadowColor: kPrimaryColor.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                // Chuyển sang màn hình nhập liệu, truyền ID template
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CvGenerationViewScreen(
                      templateId: template['id']!,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: template['image'] != null
                          ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            template['image']!,
                            fit: BoxFit.contain,
                            errorBuilder: (_,__,___) => const Icon(Icons.description_outlined, size: 50, color: Colors.grey),
                          ),
                        ),
                      )
                          : const Center(child: Icon(Icons.article_outlined, size: 60, color: Colors.grey)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Text(
                          template['name'] ?? "Mẫu CV",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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