// lib/views/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/search_view_model.dart';
import '../../../widget/user/job_card.dart';
import '../../../widget/user/search_bar.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: Consumer<SearchViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Thanh Tìm kiếm
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CustomSearchBar(
                      controller: viewModel.searchController,
                      focusNode: viewModel.searchFocusNode,
                      onChanged: viewModel.onSearchQueryChanged,
                      onSubmitted: viewModel.onSearchSubmitted,
                    ),
                  ),

                  // 2. Nội dung (Gợi ý hoặc Kết quả)
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _buildBody(context, viewModel),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SearchViewModel viewModel) {
    switch (viewModel.uiState) {
      case SearchUIState.suggesting:
        return _buildSuggestionList(viewModel);

      case SearchUIState.loading:
        return const Center(child: CircularProgressIndicator());

      case SearchUIState.error:
        return Center(
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
          return const Center(child: Text('Không tìm thấy công việc nào.'));
        }
        return _buildSearchResultList(viewModel);
    }
  }

  /// Widget hiển thị danh sách GỢI Ý
  Widget _buildSuggestionList(SearchViewModel viewModel) {
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

  /// Widget hiển thị danh sách KẾT QUẢ TÌM KIẾM
  Widget _buildSearchResultList(SearchViewModel viewModel) {
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