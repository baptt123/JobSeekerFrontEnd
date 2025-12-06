import 'package:flutter/material.dart';

class CvTemplateSelectionScreen extends StatelessWidget {
  const CvTemplateSelectionScreen({super.key});

  final List<Map<String, String>> templates = const [
    {'id': '1', 'name': 'Modern Blue', 'image': 'assets/images/cv_template_1.png'},
    {'id': '2', 'name': 'Classic Grey', 'image': 'assets/images/cv_template_2.png'},
    // {'id': '3', 'name': 'Professional', 'image': 'assets/images/cv_template_3.png'},
    // {'id': '4', 'name': 'Creative', 'image': 'assets/images/cv_template_4.png'},
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
              // Chuyển sang màn hình nhập liệu với templateId đã chọn
              Navigator.pushNamed(context, '/cv_generation', arguments: template['id']);
            },
            child: Card(
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.description, size: 50, color: Colors.grey)),
                      // Sau này thay bằng: Image.asset(template['image']!, fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
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