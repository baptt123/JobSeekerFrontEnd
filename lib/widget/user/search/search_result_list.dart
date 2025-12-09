import 'package:flutter/material.dart';
import '../../../models/job-entity.dart';
import '../../../view_models/user/search_view_model.dart';
import '../job/job_card.dart'; // Sử dụng JobCard chung
import '../../../views/login/user/job_detail_screen.dart';

class SearchResultList extends StatelessWidget {
  final SearchViewModel viewModel;
  const SearchResultList({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            'Kết quả (${viewModel.searchResults.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: viewModel.searchResults.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final JobEntity job = viewModel.searchResults[index];

              // Sử dụng JobCard đã được làm đẹp
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailScreen(jobTitle: job.title),
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