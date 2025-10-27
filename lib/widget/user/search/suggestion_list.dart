// lib/views/search/widgets/suggestion_list.dart
import 'package:flutter/material.dart';
import '../../../view_models/user/search_view_model.dart';

class SuggestionList extends StatelessWidget {
  final SearchViewModel viewModel;

  const SuggestionList({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (viewModel.suggestions.isEmpty) {
      return const Center(child: Text('Không có gợi ý nào...'));
    }

    return ListView.builder(
      key: const PageStorageKey('suggestionList'), // Giữ vị trí cuộn
      itemCount: viewModel.suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = viewModel.suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(suggestion),
          onTap: () {
            viewModel.onSuggestionTapped(suggestion);
          },
        );
      },
    );
  }
}