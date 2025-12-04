import 'package:flutter/material.dart';
import '../../../models/job-entity.dart';
import '../../../view_models/user/search_view_model.dart';
import '../../../widget/user/job_card.dart';
import '../../../views/login/user/job_detail_screen.dart'; // ✅ Import màn hình chi tiết

class SearchResultList extends StatelessWidget {
  final SearchViewModel viewModel;
  const SearchResultList({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            'Tìm thấy ${viewModel.searchResults.length} công việc',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            // Giữ vị trí cuộn khi tab qua lại (nếu cần)
            key: const PageStorageKey('searchResultList'),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: viewModel.searchResults.length,
            itemBuilder: (context, index) {
              final JobEntity job = viewModel.searchResults[index];

              // ✅ Bọc JobCard trong InkWell để bấm được
              return GestureDetector(
                onTap: () {
                  // Chuyển sang màn hình chi tiết
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailScreen(
                        jobTitle: job.title, // Truyền title (hoặc id nếu bạn đã sửa DetailScreen)
                      ),
                    ),
                  );
                },
                child: JobCard(job: job),
              );
            },
          ),
        ),
      ],
    );
  }
}