// lib/views/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/search_view_model.dart';
import '../../../widget/user/search/search_body.dart';
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
                      // Sử dụng widget SearchBody mới
                      child: SearchBody(viewModel: viewModel),
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
}