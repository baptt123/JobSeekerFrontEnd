import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../view_models/user/cv_generation_view_model.dart';
import 'cv_preview_screen.dart'; // Đảm bảo import đúng

class CvGenerationViewScreen extends StatefulWidget {
  @override
  _CvGenerationViewScreenState createState() => _CvGenerationViewScreenState();
}

class _CvGenerationViewScreenState extends State<CvGenerationViewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controller cho AI
  final TextEditingController _aiPromptController = TextEditingController();

  // Controller cho Template
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _skillController = TextEditingController();
  final _expController = TextEditingController();
  int _selectedTemplateId = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _aiPromptController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _skillController.dispose();
    _expController.dispose();
    super.dispose();
  }

  // Xử lý tạo AI
  void _handleGenerateAI(CvGenerationViewModel viewModel) async {
    File? pdfFile = await viewModel.generateCvByAi(_aiPromptController.text.trim());
    if (pdfFile != null) {
      _navigateToPreview(pdfFile.path);
    } else if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
    }
  }

  // Xử lý tạo Template
  void _handleGenerateTemplate(CvGenerationViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    // Chuẩn bị data
    Map<String, dynamic> data = {
      "fullName": _nameController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      // Chuyển chuỗi skill thành mảng object
      "skills": _skillController.text.split(',').map((e) => {"name": e.trim()}).toList(),
      "experiences": [{
        "jobTitle": "Kinh nghiệm làm việc",
        "company": "",
        "description": _expController.text,
        "duration": ""
      }]
    };

    File? pdfFile = await viewModel.generateCvFromTemplate(_selectedTemplateId, data);
    if (pdfFile != null) {
      _navigateToPreview(pdfFile.path);
    } else if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
    }
  }

  void _navigateToPreview(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CvPreviewScreen(localPath: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CvGenerationViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Tạo CV Mới"),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "Gemini AI", icon: Icon(Icons.auto_awesome)),
              Tab(text: "Template", icon: Icon(Icons.art_track)),
            ],
          ),
        ),
        body: Consumer<CvGenerationViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Đang xử lý, vui lòng chờ...")
                ],
              ));
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: AI GEMINI
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Nhập mô tả về bản thân, kinh nghiệm, kỹ năng. AI sẽ tự động thiết kế CV cho bạn.",
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _aiPromptController,
                        maxLines: 8,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Ví dụ: Tôi là Nguyễn Văn A, lập trình viên Flutter 3 năm kinh nghiệm. Kỹ năng: Dart, Firebase, Git. Đã từng làm dự án E-commerce...",
                            labelText: "Mô tả CV mong muốn"
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _handleGenerateAI(viewModel),
                        icon: Icon(Icons.create),
                        label: Text("Tạo CV với AI"),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                      ),
                    ],
                  ),
                ),

                // TAB 2: TEMPLATE
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text("Chọn mẫu và điền thông tin"),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChoiceChip(
                              label: Text("Mẫu Cơ Bản"),
                              selected: _selectedTemplateId == 1,
                              onSelected: (v) => setState(() => _selectedTemplateId = 1),
                            ),
                            SizedBox(width: 10),
                            ChoiceChip(
                              label: Text("Mẫu Hiện Đại"),
                              selected: _selectedTemplateId == 2,
                              onSelected: (v) => setState(() => _selectedTemplateId = 2),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: "Họ và tên", border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(labelText: "Số điện thoại", border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? "Không được để trống" : null,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _skillController,
                          decoration: InputDecoration(labelText: "Kỹ năng (cách nhau dấu phẩy)", border: OutlineInputBorder()),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _expController,
                          maxLines: 3,
                          decoration: InputDecoration(labelText: "Kinh nghiệm làm việc", border: OutlineInputBorder()),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _handleGenerateTemplate(viewModel),
                          icon: Icon(Icons.save),
                          label: Text("Tạo từ Template"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}