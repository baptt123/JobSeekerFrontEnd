// lib/views/search/widgets/search_body.dart
import 'package:flutter/material.dart';
import '../../../view_models/user/search_view_model.dart';
import 'search_result_list.dart';
import 'suggestion_list.dart';

class SearchBody extends StatelessWidget {
  final SearchViewModel viewModel;

  const SearchBody({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Key cho AnimatedSwitcher, giúp nó nhận diện widget con đã thay đổi
    final Key currentKey = ValueKey(viewModel.uiState);

    switch (viewModel.uiState) {
      case SearchUIState.suggesting:
        return SuggestionList(
          key: currentKey,
          viewModel: viewModel,
        );

      case SearchUIState.loading:
        return Center(key: currentKey, child: const CircularProgressIndicator());

      case SearchUIState.error:
        return Center(
          key: currentKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Lỗi: ${viewModel.errorMessage}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        );

      case SearchUIState.idle:
      case SearchUIState.success:
        if (viewModel.searchResults.isEmpty) {
          return Center(
            key: currentKey,
            child: const Text('Không tìm thấy công việc nào.'),
          );
        }
        return SearchResultList(
          key: currentKey,
          viewModel: viewModel,
        );
    }
  }
}