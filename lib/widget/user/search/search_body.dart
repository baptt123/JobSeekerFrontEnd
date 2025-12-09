import 'package:flutter/material.dart';
import '../../../view_models/user/search_view_model.dart';
import 'search_result_list.dart';
import 'suggestion_list.dart';

class SearchBody extends StatelessWidget {
  final SearchViewModel viewModel;

  const SearchBody({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // AnimatedSwitcher giúp chuyển đổi giữa các trạng thái mượt mà hơn
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (viewModel.uiState) {
      case SearchUIState.suggesting:
        return SuggestionList(viewModel: viewModel);

      case SearchUIState.loading:
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
        );

      case SearchUIState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'Đã xảy ra lỗi:\n${viewModel.errorMessage}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );

      case SearchUIState.idle:
      case SearchUIState.success:
        if (viewModel.searchResults.isEmpty) {
          // Trạng thái Empty đẹp hơn
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search_off_rounded, size: 60, color: const Color(0xFF6C63FF).withOpacity(0.5)),
                ),
                const SizedBox(height: 20),
                Text(
                  viewModel.uiState == SearchUIState.idle
                      ? 'Nhập từ khóa để tìm kiếm việc làm'
                      : 'Không tìm thấy công việc nào',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }
        return SearchResultList(viewModel: viewModel);
    }
  }
}