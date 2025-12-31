import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../../../services/cv_service.dart';
import 'cv_preview_screen.dart';

class CvGenerationViewScreen extends StatefulWidget {
  final int templateId;

  const CvGenerationViewScreen({Key? key, required this.templateId}) : super(key: key);

  @override
  _CvGenerationViewScreenState createState() => _CvGenerationViewScreenState();
}

class _CvGenerationViewScreenState extends State<CvGenerationViewScreen> {
  final _formKey = GlobalKey<FormState>();
  final CvGenerationService _cvService = CvGenerationService();
  bool _isLoading = false;

  // Các controller quản lý input
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _skillCtrl = TextEditingController();
  final TextEditingController _expCtrl = TextEditingController();

  Future<void> _submitAndGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Map dữ liệu gửi xuống Backend
    final data = {
      'fullName': _nameCtrl.text,
      'email': _emailCtrl.text,
      'phone': _phoneCtrl.text,
      'skills': _skillCtrl.text,
      'experience': _expCtrl.text,
      // Backend sẽ tự lấy avatarUrl từ User Profile nếu không truyền lên
    };

    try {
      // 1. Gọi API tạo CV theo Template
      final List<int> pdfBytes = await _cvService.generateCvTemplate(widget.templateId, data);

      // 2. Chuyển sang màn hình xem trước
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CvPreviewScreen(
              fileData: Uint8List.fromList(pdfBytes),
              title: "Kết quả tạo CV",
            ),
          ),
        );
      }
    } catch (e) {
      _showError("Tạo CV thất bại: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    showDialog(context: context, builder: (_) => AlertDialog(title: Text("Lỗi"), content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nhập thông tin CV")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: "Họ và tên"),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: _phoneCtrl,
                decoration: InputDecoration(labelText: "Số điện thoại"),
              ),
              TextFormField(
                controller: _skillCtrl,
                decoration: InputDecoration(labelText: "Kỹ năng (cách nhau dấu phẩy)"),
                maxLines: 2,
              ),
              TextFormField(
                controller: _expCtrl,
                decoration: InputDecoration(labelText: "Kinh nghiệm làm việc"),
                maxLines: 4,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitAndGenerate,
                child: Text("Tạo CV ngay"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}