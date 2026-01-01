import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Cần thêm vào pubspec.yaml
import '../../../services/cv_service.dart';
import 'cv_preview_screen.dart'; // Màn hình xem PDF

class ManageCvScreen extends StatefulWidget {
  @override
  _ManageCvScreenState createState() => _ManageCvScreenState();
}

class _ManageCvScreenState extends State<ManageCvScreen> {
  final CVService _cvService = CVService();
  List<dynamic> _cvs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCVs();
  }

  void _loadCVs() async {
    setState(() => _isLoading = true);
    try {
      _cvs = await _cvService.getMyCVs();
    } catch (e) {
      _showDialog("Lỗi", e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // CHỨC NĂNG 1: UPLOAD & TRÍCH XUẤT
  void _pickAndUploadCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      // Validate Frontend: Đuôi file
      if (!file.path.endsWith('.pdf')) {
        _showDialog("Lỗi", "Vui lòng chỉ chọn file định dạng PDF.");
        return;
      }

      setState(() => _isLoading = true);
      try {
        var res = await _cvService.uploadCV(file);
        _showDialog("Thành công", "Từ khoá rút trích: ${res['keywords']}");
        _loadCVs();
      } catch (e) {
        _showDialog("Lỗi Upload", e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // CHỨC NĂNG 4: SET DEFAULT
  void _setDefault(int id) async {
    try {
      await _cvService.setDefaultCV(id);
      _loadCVs(); // Reload để cập nhật UI state
    } catch (e) {
      _showDialog("Lỗi", e.toString());
    }
  }

  // CHỨC NĂNG 4: SOFT DELETE
  void _deleteCV(int id) async {
    bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Xác nhận"),
          content: Text("Bạn có chắc muốn xóa CV này?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Hủy")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Xóa")),
          ],
        )
    ) ?? false;

    if (confirm) {
      try {
        await _cvService.deleteCV(id);
        _loadCVs();
      } catch (e) {
        _showDialog("Lỗi", e.toString());
      }
    }
  }

  // Helper View
  void _viewCV(String url) {
    // Nếu là URL online, truyền vào PDF Viewer (cần xử lý download file về temp để view nếu lib yêu cầu file local)
    Navigator.push(context, MaterialPageRoute(builder: (_) => CvPreviewScreen(fileUrl: url)));
  }

  void _showDialog(String title, String content) {
    showDialog(context: context, builder: (_) => AlertDialog(title: Text(title), content: Text(content), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text("OK"))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quản lý CV")),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: _cvs.length,
        itemBuilder: (context, index) {
          final cv = _cvs[index];
          return Card(
            color: cv['is_default'] ? Colors.blue[50] : Colors.white,
            child: ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(cv['title'] ?? 'CV không tên'),
              subtitle: Text(cv['is_default'] ? "Mặc định" : "Ngày tạo: ${cv['created_at']}"),
              trailing: PopupMenuButton(
                onSelected: (value) {
                  if (value == 'view') _viewCV(cv['file_url']);
                  if (value == 'default') _setDefault(cv['cv_id']);
                  if (value == 'delete') _deleteCV(cv['cv_id']);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'view', child: Text("Xem nội dung")),
                  if (!cv['is_default']) PopupMenuItem(value: 'default', child: Text("Đặt làm mặc định")),
                  PopupMenuItem(value: 'delete', child: Text("Xóa CV")),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadCV,
        child: Icon(Icons.upload_file),
      ),
    );
  }
}