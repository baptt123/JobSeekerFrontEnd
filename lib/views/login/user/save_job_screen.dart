import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/home_view_model.dart';
import '../../../view_models/user/save_job_view_model.dart';
import '../../../widget/user/save_job/save_job_card.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({Key? key}) : super(key: key);

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SavedJobsViewModel>(context, listen: false).fetchSavedJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Công Việc Đã Lưu',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        // Ẩn nút back nếu đây là tab trong MainScreen (tuỳ chọn)
        automaticallyImplyLeading: false,
      ),
      body: Consumer<SavedJobsViewModel>(
        builder: (context, viewModel, child) {
          // 1. Trạng thái Loading
          if (viewModel.state == SavedJobsState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. ✅ Trạng thái Chưa Đăng Nhập (Guest)
          if (viewModel.state == SavedJobsState.unauthorized) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_clock_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Vui lòng đăng nhập để xem công việc đã lưu',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Chuyển sang màn hình Login
                      Navigator.pushNamed(context, '/login').then((_) {
                        // Khi quay lại từ Login (nếu đăng nhập thành công), tải lại dữ liệu
                        viewModel.fetchSavedJobs();
                      });
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Đăng nhập ngay'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // 3. Trạng thái Lỗi
          if (viewModel.state == SavedJobsState.error) {
            return Center(child: Text('Lỗi: ${viewModel.error}'));
          }

          // 4. Trạng thái Rỗng
          if (viewModel.savedJobs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Bạn chưa lưu công việc nào.'),
                ],
              ),
            );
          }

          // 5. Trạng thái Hiển thị danh sách
          // Lấy HomeViewModel để đồng bộ khi bỏ lưu
          final homeViewModel = context.read<HomeViewModel>();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.savedJobs.length,
            itemBuilder: (context, index) {
              final job = viewModel.savedJobs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SavedJobCard(
                  job: job,
                  onUnsavePressed: () {
                    viewModel.unsaveJob(
                      job,
                      context,
                      homeViewModel,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}