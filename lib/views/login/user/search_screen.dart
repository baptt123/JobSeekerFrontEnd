import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/search_view_model.dart';
import '../../../widget/user/search/search_body.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy theme để dùng chung cho toàn màn hình
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: Consumer<SearchViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            // BỎ kBackgroundColor cứng, dùng theme
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: _buildAppBar(context, vm),
            body: SearchBody(viewModel: vm),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, SearchViewModel vm) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Màu nền ô input: Dark dùng xám đậm, Light dùng xám rất nhạt
    final inputFillColor = isDark ? Colors.grey[800] : Colors.grey[100];
    final inputBorderColor = isDark ? Colors.grey[700]! : Colors.grey.shade200;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[500];

    return AppBar(
      // Màu nền AppBar theo Theme
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      // Icon Back tự động theo Theme
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Container(
        margin: const EdgeInsets.only(right: 16),
        height: 44,
        decoration: BoxDecoration(
          color: inputFillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: inputBorderColor),
        ),
        child: TextField(
          controller: vm.searchController,
          focusNode: vm.searchFocusNode,
          textAlignVertical: TextAlignVertical.center,
          // Màu chữ nhập vào
          style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 15),
          decoration: InputDecoration(
            hintText: "Tìm kiếm việc làm, công ty...",
            hintStyle: TextStyle(color: hintColor, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: hintColor, size: 22),
            suffixIcon: vm.searchController.text.isNotEmpty
                ? GestureDetector(
              onTap: () {
                vm.searchController.clear();
                vm.onSearchQueryChanged('');
              },
              child: Icon(Icons.close, color: hintColor, size: 18),
            )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          onChanged: vm.onSearchQueryChanged,
          onSubmitted: vm.onSearchSubmitted,
        ),
      ),
    );
  }
}