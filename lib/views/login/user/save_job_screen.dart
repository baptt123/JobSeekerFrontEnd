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
    // Tải (hoặc làm mới) danh sách job đã lưu mỗi khi vào màn hình
    // Dùng addPostFrameCallback để đảm bảo context đã sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Gọi hàm fetchSavedJobs từ ViewModel
      Provider.of<SavedJobsViewModel>(context, listen: false).fetchSavedJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Màu nền giống ảnh
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Saved Jobs',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<SavedJobsViewModel>(
        builder: (context, viewModel, child) {
          // Trạng thái đang tải
          if (viewModel.state == SavedJobsState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Trạng thái lỗi
          if (viewModel.state == SavedJobsState.error) {
            return Center(child: Text('Lỗi: ${viewModel.error}'));
          }

          // Trạng thái thành công nhưng rỗng
          if (viewModel.savedJobs.isEmpty) {
            return const Center(child: Text('Bạn chưa lưu job nào.'));
          }

          // Trạng thái thành công và có dữ liệu
          // Lấy HomeViewModel để truyền vào hàm unsave
          final homeViewModel = context.read<HomeViewModel>();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.savedJobs.length,
            itemBuilder: (context, index) {
              final job = viewModel.savedJobs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                // Sử dụng Widget SavedJobCard (code ở bên dưới)
                child: SavedJobCard(
                  job: job,
                  onUnsavePressed: () {
                    // Gọi hàm unsave từ view model
                    viewModel.unsaveJob(
                      job,
                      context,
                      homeViewModel, // Truyền HomeViewModel để đồng bộ
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