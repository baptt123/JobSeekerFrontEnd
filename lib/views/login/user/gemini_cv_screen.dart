import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/user/cv_generation_view_model.dart';
import 'cv_preview_screen.dart';

class GeminiCvScreen extends StatefulWidget {
  @override
  _GeminiCvScreenState createState() => _GeminiCvScreenState();
}

class _GeminiCvScreenState extends State<GeminiCvScreen> {
  final _promptCtrl = TextEditingController();

  void _generate(BuildContext context) async {
    if (_promptCtrl.text.isEmpty) return;

    final vm = Provider.of<CvGenerationViewModel>(context, listen: false);
    final pdfBytes = await vm.generateByGemini(_promptCtrl.text);

    if (pdfBytes != null) {
      // Chuyển sang màn hình Preview với dữ liệu bytes
      Navigator.push(context, MaterialPageRoute(
          builder: (_) => CvPreviewScreen(fileData: pdfBytes, title: "CV tạo bởi AI")
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tạo CV thất bại")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Đảm bảo có Provider bao bọc hoặc đã khai báo ở main
    return ChangeNotifierProvider.value(
      value: Provider.of<CvGenerationViewModel>(context), // Nếu đã khai báo ở main
      // Hoặc create: (_) => CvGenerationViewModel(), // Nếu chưa khai báo global
      child: Scaffold(
        appBar: AppBar(title: Text("Tạo CV với Gemini AI")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _promptCtrl,
                decoration: InputDecoration(
                  labelText: "Nhập mô tả về bản thân (Kinh nghiệm, kỹ năng...)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              Consumer<CvGenerationViewModel>(
                builder: (_, vm, __) => vm.isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton.icon(
                  onPressed: () => _generate(context),
                  icon: Icon(Icons.auto_awesome),
                  label: Text("Tạo CV ngay"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}