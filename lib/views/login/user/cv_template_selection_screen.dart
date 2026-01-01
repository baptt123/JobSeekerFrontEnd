import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../services/cv_service.dart';
import 'cv_preview_screen.dart';

class CvTemplateSelectionScreen extends StatefulWidget {
  @override
  _CvTemplateSelectionScreenState createState() => _CvTemplateSelectionScreenState();
}

class _CvTemplateSelectionScreenState extends State<CvTemplateSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final CVService _cvService = CVService();
  int _selectedTemplate = 1;
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _expController = TextEditingController(); // Demo simple string for simplicity
  final _skillController = TextEditingController();

  void _generateTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Map data
    Map<String, dynamic> data = {
      "fullName": _nameController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      // Xử lý đơn giản cho demo: split string thành array object
      "skills": _skillController.text.split(',').map((e) => {"name": e.trim()}).toList(),
      "experiences": [{
        "jobTitle": "Vị trí cũ",
        "company": "Công ty cũ",
        "description": _expController.text,
        "duration": "2020-2022"
      }]
    };

    try {
      List<int> bytes = await _cvService.generateCVTemplate(_selectedTemplate, data);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/cv_template_gen.pdf');
      await file.writeAsBytes(bytes);

      Navigator.push(context, MaterialPageRoute(builder: (_) => CvPreviewScreen(localPath: file.path)));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chọn Template CV")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Chọn Template
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ChoiceChip(label: Text("Template 1"), selected: _selectedTemplate == 1, onSelected: (v) => setState(() => _selectedTemplate = 1)),
                  ChoiceChip(label: Text("Template 2"), selected: _selectedTemplate == 2, onSelected: (v) => setState(() => _selectedTemplate = 2)),
                ],
              ),
              SizedBox(height: 20),
              // Form Fields
              TextFormField(controller: _nameController, decoration: InputDecoration(labelText: "Họ tên"), validator: (v) => v!.isEmpty ? "Cần nhập họ tên" : null),
              TextFormField(controller: _emailController, decoration: InputDecoration(labelText: "Email"), validator: (v) => v!.isEmpty ? "Cần nhập email" : null),
              TextFormField(controller: _phoneController, decoration: InputDecoration(labelText: "SĐT"), validator: (v) => v!.isEmpty ? "Cần nhập SĐT" : null),
              TextFormField(controller: _skillController, decoration: InputDecoration(labelText: "Kỹ năng (cách nhau dấu phẩy)")),
              TextFormField(controller: _expController, decoration: InputDecoration(labelText: "Kinh nghiệm làm việc"), maxLines: 3),

              SizedBox(height: 20),
              _isLoading ? CircularProgressIndicator() : ElevatedButton(onPressed: _generateTemplate, child: Text("Tạo & Xem trước"))
            ],
          ),
        ),
      ),
    );
  }
}