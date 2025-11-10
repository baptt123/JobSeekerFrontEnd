//
// 📄 [SỬA ĐỔI/TẠO MỚI] baptt123/jobseekerfrontend/JobSeekerFrontEnd-develop/lib/views/login/user/gemini_cv_screen.dart
//
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // 👈 Xem trước PDF
import 'package:job_seeker_frontend/view_models/user/cv_generation_view_model.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart'; // 👈 Lưu file
import 'package:open_file/open_file.dart'; // 👈 Mở file
import 'dart:io'; // 👈 Dùng class 'File'

class GeminiCvScreen extends StatefulWidget {
  const GeminiCvScreen({Key? key}) : super(key: key);

  @override
  State<GeminiCvScreen> createState() => _GeminiCvScreenState();
}

class _GeminiCvScreenState extends State<GeminiCvScreen> {
  final _promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset trạng thái khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CvGenerationViewModel>(context, listen: false).resetState();
    });
  }

  void _handleGenerateCv() {
    if (_promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập yêu cầu (prompt) của bạn')),
      );
      return;
    }

    // Gọi ViewModel
    Provider.of<CvGenerationViewModel>(context, listen: false)
        .generateCv(_promptController.text);
  }

  // Hàm tự động tải xuống (lưu và mở file)
  Future<void> _saveAndOpenFile(Uint8List pdfData) async {
    try {
      // 1. Lấy thư mục
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/gemini_cv_${DateTime.now().millisecond}.pdf';

      // 2. Lưu file
      final file = File(filePath);
      await file.writeAsBytes(pdfData);

      // 3. Mở file
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu file! Đang mở...')),
      );
      await OpenFile.open(filePath);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu/mở file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo CV bằng Gemini AI'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Consumer<CvGenerationViewModel>(
        builder: (context, viewModel, child) {

          // Tự động tải xuống KHI CHUYỂN SANG state 'success'
          // (Cần lắng nghe sự thay đổi của state)
          // -> Chúng ta sẽ làm việc này trong _buildResultArea

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPromptInput(viewModel.state),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.auto_awesome),
                  label: Text('Tạo CV ngay'),
                  // Vô hiệu hóa nút khi đang loading
                  onPressed: viewModel.state == CvGenerationState.loading
                      ? null
                      : _handleGenerateCv,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20),
                // Khu vực hiển thị kết quả
                Expanded(
                  child: _buildResultArea(viewModel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget nhập prompt
  Widget _buildPromptInput(CvGenerationState state) {
    return TextField(
      controller: _promptController,
      maxLines: 5,
      // Không cho sửa khi đang loading
      readOnly: state == CvGenerationState.loading,
      decoration: InputDecoration(
        labelText: 'Mô tả CV bạn muốn',
        hintText: 'Ví dụ: "Tạo CV cho sinh viên IT mới ra trường..."',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: state == CvGenerationState.loading ? Colors.grey[200] : Colors.grey[100],
      ),
    );
  }

  // Widget hiển thị kết quả (Loading hoặc PDF)
  Widget _buildResultArea(CvGenerationViewModel viewModel) {
    // Dùng switch-case với state của ViewModel
    switch (viewModel.state) {
      case CvGenerationState.initial:
        return Center(
          child: Text('Nhập yêu cầu của bạn và nhấn "Tạo CV"'),
        );

      case CvGenerationState.loading:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Gemini đang viết CV cho bạn...',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );

      case CvGenerationState.error:
        return Center(
          child: Text(
            'Lỗi: ${viewModel.errorMessage}',
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        );

      case CvGenerationState.success:
      // Tự động tải xuống khi state là success
        if (viewModel.pdfData != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _saveAndOpenFile(viewModel.pdfData!);
          });
        }

        // Hiển thị PDF xem trước
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: (viewModel.pdfData != null)
              ? PDFView(
            pdfData: viewModel.pdfData!,
          )
              : Center(child: Text('Không có dữ liệu PDF')),
        );
    }
  }
}