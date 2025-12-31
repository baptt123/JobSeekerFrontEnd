import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/user/scan_pdf_view_model.dart';

class ScanPdfScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để lắng nghe ViewModel
    return ChangeNotifierProvider(
      create: (_) => ScanPdfViewModel(),
      child: Scaffold(
        appBar: AppBar(title: Text("Upload CV & Rút trích Keyword")),
        body: Consumer<ScanPdfViewModel>(
          builder: (ctx, viewModel, child) {
            // Lắng nghe lỗi hoặc keyword để hiện Dialog
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (viewModel.error != null) {
                _showDialog(ctx, "Lỗi", viewModel.error!);
                viewModel.clearState();
              }
              if (viewModel.keywords != null) {
                _showDialog(ctx, "Thành công", "Keywords tìm thấy: ${viewModel.keywords}");
                viewModel.clearState();
              }
            });

            return Center(
              child: viewModel.isLoading
                  ? CircularProgressIndicator()
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_file, size: 100, color: Colors.blue),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => viewModel.pickAndUploadPdf(),
                    child: Text("Chọn File PDF"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(context: context, builder: (_) => AlertDialog(title: Text(title), content: Text(content)));
  }
}