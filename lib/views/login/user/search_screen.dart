// Code này thay thế hoàn toàn search_screen.dart cũ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/search_view_model.dart';
import '../../../widget/user/search/search_body.dart';
import '../../../utils/app_colors.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: Consumer<SearchViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
              elevation: 0,
              leading: const BackButton(color: Colors.grey),
              title: TextField(
                controller: vm.searchController,
                focusNode: vm.searchFocusNode,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Search jobs, companies...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                ),
                onChanged: vm.onSearchQueryChanged,
                onSubmitted: vm.onSearchSubmitted,
              ),
              actions: [
                IconButton(icon: const Icon(Icons.filter_list, color: AppColors.primary), onPressed: () { /* Open Filter */ }),
              ],
            ),
            body: SearchBody(viewModel: vm), // Widget này giữ nguyên logic hiển thị list
          );
        },
      ),
    );
  }
}