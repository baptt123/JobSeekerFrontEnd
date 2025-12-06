// lib/views/login/user/cv_template_selection_screen.dart

import 'package:flutter/material.dart';
// ✅ IMPORT màn hình đích
import 'cv_generation_view_screen.dart';

class CvTemplateSelectionScreen extends StatelessWidget {
  const CvTemplateSelectionScreen({super.key});

  final List<Map<String, String>> templates = const [
    {'id': '1', 'name': 'Modern Blue', 'image': 'assets/icon/cv_template_1.png'},
    {'id': '2', 'name': 'Classic Grey', 'image': 'assets/icon/cv_template_2.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn mẫu CV')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return GestureDetector(
            onTap: () {
              // ✅ FIX: Dùng Navigator.push thay vì pushNamed để tránh lỗi "Could not find generator"
              // và truyền trực tiếp tham số templateId vào màn hình đích.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CvGenerationViewScreen(
                    templateId: template['id'],
                  ),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: template['image'] != null && template['image']!.contains('assets')
                          ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset(
                          template['image']!,
                          fit: BoxFit.contain,
                          errorBuilder: (_,__,___) => const Icon(Icons.description, size: 50, color: Colors.grey),
                        ),
                      )
                          : const Center(child: Icon(Icons.description, size: 50, color: Colors.grey)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      template['name']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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