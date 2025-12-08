import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/manage_cv_view_model.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kBackgroundColor = Color(0xFFF9F9F9);

class ManageCvScreen extends StatelessWidget {
  const ManageCvScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ManageCvViewModel(),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: const Text("Quản lý Hồ sơ (CV)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          centerTitle: true,
          backgroundColor: kBackgroundColor,
          elevation: 0,
          leading: const BackButton(color: Colors.black87),
        ),
        body: Consumer<ManageCvViewModel>(
          builder: (context, vm, _) {
            // 1. Loading / Uploading
            if (vm.state == ManageCvState.loading || vm.state == ManageCvState.uploading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: kPrimaryColor),
                    const SizedBox(height: 16),
                    Text(vm.state == ManageCvState.uploading ? "Đang tải lên..." : "Đang tải danh sách...", style: const TextStyle(color: Colors.grey))
                  ],
                ),
              );
            }

            // 2. [CẬP NHẬT] Xử lý Lỗi
            if (vm.state == ManageCvState.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(vm.errorMessage, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => vm.fetchCvs(), // Thử lại
                      style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: Colors.white),
                      child: const Text("Thử lại"),
                    )
                  ],
                ),
              );
            }

            // 3. UI Chính
            return RefreshIndicator(
              onRefresh: vm.fetchCvs,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUploadButton(context, vm),
                    const SizedBox(height: 24),
                    const Text("Danh sách CV của bạn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (vm.cvs.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: Text("Chưa có CV nào", style: TextStyle(color: Colors.grey))))
                    else
                      ...vm.cvs.map((cv) => _buildCvCard(context, vm, cv)).toList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ... (Giữ nguyên các widget con _buildUploadButton, _buildCvCard)
  Widget _buildUploadButton(BuildContext context, ManageCvViewModel vm) {
    return GestureDetector(
      onTap: () => vm.uploadNewCv(context),
      child: Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: kPrimaryColor, width: 1.5, style: BorderStyle.solid)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_outlined, color: kPrimaryColor, size: 32), const SizedBox(height: 8), const Text("Tải lên CV mới (PDF)", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Widget _buildCvCard(BuildContext context, ManageCvViewModel vm, dynamic cv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFFFFECEC), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent)),
        title: Text(cv.title ?? "CV Không tên", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Text("Ngày tải: ${cv.createdAt.toString().substring(0, 10)}"),
          if (cv.isDefault) Container(margin: const EdgeInsets.only(top: 6), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text("Đang sử dụng chính", style: TextStyle(color: kPrimaryColor, fontSize: 10, fontWeight: FontWeight.bold)))
        ]),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'default') vm.setDefault(cv.cvId, context);
            else if (value == 'delete') vm.deleteCv(cv.cvId, context);
          },
          itemBuilder: (context) => [
            if (!cv.isDefault) const PopupMenuItem(value: 'default', child: Row(children: [Icon(Icons.check_circle_outline, color: kPrimaryColor), SizedBox(width: 8), Text("Đặt làm CV chính")])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red), SizedBox(width: 8), Text("Xóa")])),
          ],
        ),
      ),
    );
  }
}