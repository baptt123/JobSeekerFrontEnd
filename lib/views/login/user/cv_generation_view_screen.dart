import 'package:flutter/material.dart';

class CvGenerationViewScreen extends StatefulWidget {
  final String? templateId;
  const CvGenerationViewScreen({super.key, this.templateId});

  @override
  State<CvGenerationViewScreen> createState() => _CvGenerationViewScreenState();
}

class _CvGenerationViewScreenState extends State<CvGenerationViewScreen> {
  // Các controller quản lý input
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _skillsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập thông tin CV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () {
              // Chuyển dữ liệu sang màn hình Preview
              Navigator.pushNamed(context, '/cv_preview');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Thông tin cá nhân'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Họ và tên', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Kinh nghiệm làm việc'),
            TextField(
              controller: _experienceController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Mô tả kinh nghiệm...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Học vấn'),
            TextField(
              controller: _educationController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Trường học, bằng cấp...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Kỹ năng'),
            TextField(
              controller: _skillsController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Các kỹ năng (cách nhau bởi dấu phẩy)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Gọi ViewModel để lưu hoặc tạo PDF
                },
                icon: const Icon(Icons.save),
                label: const Text('Lưu CV'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }
}