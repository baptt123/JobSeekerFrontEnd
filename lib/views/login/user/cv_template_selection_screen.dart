import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; // Cần thêm vào pubspec.yaml
import 'package:path_provider/path_provider.dart';
import '../../../services/cv_service.dart';
import '../../../services/ai_cv_generator_service.dart'; // Import Service AI
import 'cv_preview_screen.dart';

class CvTemplateSelectionScreen extends StatefulWidget {
  @override
  _CvTemplateSelectionScreenState createState() => _CvTemplateSelectionScreenState();
}

class _CvTemplateSelectionScreenState extends State<CvTemplateSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final CVService _cvService = CVService();
  final AiCvGeneratorService _aiService = AiCvGeneratorService();
  final ImagePicker _picker = ImagePicker();

  int _selectedTemplate = 1;
  bool _isLoading = false;
  File? _avatarImage;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _expController = TextEditingController();
  final _skillController = TextEditingController();

  // Hàm chọn ảnh
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _avatarImage = File(image.path);
      });
    }
  }

  // Hàm điền tự động bằng AI
  Future<void> _fillWithAI() async {
    // 1. Hỏi prompt người dùng
    String? prompt = await showDialog<String>(
        context: context,
        builder: (context) {
          String input = "";
          return AlertDialog(
            title: const Text("Điền tự động với AI"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Nhập mô tả bản thân, hoặc dán nội dung LinkedIn của bạn:"),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (v) => input = v,
                  decoration: const InputDecoration(
                    hintText: "VD: Tôi là Lập trình viên Flutter 2 năm kinh nghiệm...",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, input),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text("Điền ngay", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
    );

    if (prompt == null || prompt.trim().isEmpty) return;

    // 2. Gọi AI Service
    setState(() => _isLoading = true);
    try {
      // Giả định AiCvGeneratorService có hàm trả về DTO từ prompt
      final dto = await _aiService.generateCvFromPrompt(prompt);

      // 3. Fill data vào form
      setState(() {
        _nameController.text = dto.fullName ?? "";
        _emailController.text = dto.email ?? "";
        _phoneController.text = dto.phone ?? "";

        // Gộp kỹ năng thành chuỗi
        if (dto.skills != null) {
          _skillController.text = dto.skills!.map((s) => s.name).join(", ");
        }

        // Gộp kinh nghiệm thành chuỗi mô tả
        if (dto.experiences != null) {
          _expController.text = dto.experiences!.map((e) =>
          "- ${e.jobTitle} tại ${e.company}: ${e.description}"
          ).join("\n\n");
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã điền thông tin từ AI!")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi AI: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _generateTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Map data
    Map<String, dynamic> data = {
      "fullName": _nameController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      "skills": _skillController.text.split(',').map((e) => {"name": e.trim()}).toList(),
      "experiences": [{
        "jobTitle": "Work Experience", // Placeholder title
        "company": "",
        "description": _expController.text,
        "duration": ""
      }],
      // Truyền đường dẫn ảnh nếu có (Backend cần xử lý file này)
      "avatarPath": _avatarImage?.path
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
      appBar: AppBar(title: const Text("Chọn Template CV")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Chọn Ảnh
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _avatarImage != null ? FileImage(_avatarImage!) : null,
                  child: _avatarImage == null ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey) : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text("Chạm để tải ảnh đại diện", style: TextStyle(color: Colors.grey)),

              const SizedBox(height: 20),

              // Nút AI Autofill
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _fillWithAI,
                  icon: const Icon(Icons.auto_awesome, color: Colors.purple),
                  label: const Text("Tự động điền thông tin bằng AI"),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.purple),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Chọn Template
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ChoiceChip(label: const Text("Template 1"), selected: _selectedTemplate == 1, onSelected: (v) => setState(() => _selectedTemplate = 1)),
                  ChoiceChip(label: const Text("Template 2"), selected: _selectedTemplate == 2, onSelected: (v) => setState(() => _selectedTemplate = 2)),
                ],
              ),
              const SizedBox(height: 20),

              // Form Fields
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "Họ tên", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Cần nhập họ tên" : null),
              const SizedBox(height: 12),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Cần nhập email" : null),
              const SizedBox(height: 12),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: "SĐT", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? "Cần nhập SĐT" : null),
              const SizedBox(height: 12),
              TextFormField(controller: _skillController, decoration: const InputDecoration(labelText: "Kỹ năng (cách nhau dấu phẩy)", border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextFormField(controller: _expController, decoration: const InputDecoration(labelText: "Kinh nghiệm làm việc", border: OutlineInputBorder()), maxLines: 5),

              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                    onPressed: _generateTemplate,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    child: const Text("Tạo & Xem trước", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}