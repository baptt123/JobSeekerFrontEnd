// lib/views/search/widgets/search_result_list.dart
import 'package:flutter/material.dart';
import '../../../view_models/user/search_view_model.dart';
import '../../../widget/user/job_card.dart';

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
            '${viewModel.searchResults.length} Jobs Available',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            key: const PageStorageKey('searchResultList'), // Giữ vị trí cuộn
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: viewModel.searchResults.length,
            itemBuilder: (context, index) {
              final job = viewModel.searchResults[index];
              return JobCard(job: job);
            },
          ),
        ),
      ],
    );
  }
}