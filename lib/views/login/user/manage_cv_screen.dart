import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../services/cv_service.dart';
import '../../../models/user-cv-entity.dart'; // Import Entity đã cập nhật
import 'cv_preview_screen.dart';

class ManageCvScreen extends StatefulWidget {
  const ManageCvScreen({Key? key}) : super(key: key);

  @override
  _ManageCvScreenState createState() => _ManageCvScreenState();
}

class _ManageCvScreenState extends State<ManageCvScreen> {
  final CVService _cvService = CVService();
  List<dynamic> _rawCvs = []; // Lưu dữ liệu gốc từ API
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCVs();
  }

  // Lấy danh sách CV từ Backend
  void _loadCVs() async {
    setState(() => _isLoading = true);
    try {
      _rawCvs = await _cvService.getMyCVs();
    } catch (e) {
      _showDialog("Lỗi tải danh sách", e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Logic Upload và Phân tích AI
  void _pickAndUploadSmartCV() async {
    // 1. Chọn File PDF
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      // Validate phía Client
      if (!file.path.toLowerCase().endsWith('.pdf')) {
        _showDialog("Sai định dạng", "Vui lòng chỉ chọn file định dạng .pdf");
        return;
      }

      setState(() => _isLoading = true);

      // 2. Gửi file xuống Backend xử lý
      try {
        var res = await _cvService.uploadAndParseCv(file);

        // 3. Xử lý kết quả trả về
        String message = "CV hợp lệ!\n";
        var extracted = res['extracted_data'];

        if (extracted != null) {
          int skillCount = (extracted['skills'] as List?)?.length ?? 0;
          int keywordCount = (extracted['keywords'] as List?)?.length ?? 0;
          message += "Đã trích xuất được:\n- $skillCount kỹ năng chuyên môn\n- $keywordCount từ khóa năng lực";
        }

        _showDialog("Phân tích thành công", message);
        _loadCVs(); // Tải lại danh sách để hiện CV mới
      } catch (e) {
        // Lỗi từ Backend (VD: File không phải CV, lỗi server...)
        _showDialog("Lỗi xử lý", e.toString().replaceAll("Exception:", "").trim());
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Đặt CV mặc định
  void _setDefault(int id) async {
    try {
      await _cvService.setDefaultCV(id);
      _loadCVs();
    } catch (e) {
      _showDialog("Lỗi", e.toString());
    }
  }

  // Xóa CV
  void _deleteCV(int id) async {
    bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Xác nhận"),
          content: const Text("Bạn có chắc muốn xóa CV này?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
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

  // Xem chi tiết (Preview PDF)
  void _viewCV(String url) {
    if (url.isEmpty) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => CvPreviewScreen(localPath: url)));
  }

  void _showDialog(String title, String content) {
    if (!mounted) return;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("OK"))]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý CV")),
      body: Stack(
        children: [
          // Lớp 1: Danh sách CV
          _rawCvs.isEmpty && !_isLoading
              ? const Center(child: Text("Bạn chưa có CV nào. Hãy upload ngay!", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Chừa chỗ cho FAB
            itemCount: _rawCvs.length,
            itemBuilder: (context, index) {
              // Convert Map sang Entity để dùng các getter tiện ích
              final cvData = _rawCvs[index];
              final UserCvEntity cv = UserCvEntity.fromJson(cvData);

              final isDefault = cv.isDefault == true;

              // Highlight màu nền nếu là mặc định
              final cardColor = isDefault
                  ? Theme.of(context).primaryColor.withOpacity(0.08)
                  : Theme.of(context).cardTheme.color;

              // Lấy top 3 kỹ năng hiển thị preview
              final skillsList = cv.extractedSkills; // Getter từ Entity
              final skillsPreview = skillsList.take(3).join(", ");
              final remainSkills = skillsList.length > 3 ? "+${skillsList.length - 3}" : "";

              return Card(
                color: cardColor,
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: InkWell(
                  onTap: () => _viewCV(cv.cvUrl ?? ''),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Icon PDF
                        Container(
                          width: 40,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3))
                          ),
                          child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                        ),
                        const SizedBox(width: 12),

                        // Nội dung chính
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tên CV
                              Text(
                                cv.title ?? 'CV Không tên',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),

                              // Hiển thị Kỹ năng (Feature mới)
                              if (skillsPreview.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.auto_awesome, size: 14, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "$skillsPreview $remainSkills",
                                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Ngày tạo & Trạng thái
                              Row(
                                children: [
                                  if (isDefault)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(4)
                                      ),
                                      child: const Text("Mặc định", style: TextStyle(color: Colors.white, fontSize: 10)),
                                    ),
                                  Text(
                                    "Ngày tạo: ${cv.createdAt?.toString().substring(0, 10) ?? 'N/A'}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        // Menu Option
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'view') _viewCV(cv.cvUrl ?? '');
                            if (value == 'default') _setDefault(cv.cvId!);
                            if (value == 'delete') _deleteCV(cv.cvId!);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'view',
                                child: Row(children: [Icon(Icons.visibility, size: 20, color: Colors.blueGrey), SizedBox(width: 10), Text("Xem nội dung")])
                            ),
                            if (!isDefault)
                              const PopupMenuItem(
                                  value: 'default',
                                  child: Row(children: [Icon(Icons.check_circle, size: 20, color: Colors.green), SizedBox(width: 10), Text("Đặt làm mặc định")])
                              ),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 10), Text("Xóa CV", style: TextStyle(color: Colors.red))])
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Lớp 2: Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text("Đang phân tích CV với AI...", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Vui lòng đợi trong giây lát", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _pickAndUploadSmartCV,
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.upload_file),
        label: const Text("Upload CV (AI Scan)"),
      ),
    );
  }
}