import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/search_view_model.dart';
import '../../../widget/user/search/search_body.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kBackgroundColor = Color(0xFFF8F9FD);

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: Consumer<SearchViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: kBackgroundColor,
            appBar: _buildAppBar(context, vm),
            // ✅ Đã xóa Column và phần FilterChips gây lỗi
            // SearchBody được đưa ra làm body chính, tự động chiếm hết không gian
            body: SearchBody(viewModel: vm),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, SearchViewModel vm) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Container(
        margin: const EdgeInsets.only(right: 16),
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextField(
          controller: vm.searchController,
          focusNode: vm.searchFocusNode,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          decoration: InputDecoration(
            hintText: "Tìm kiếm việc làm, công ty...",
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 22),
            suffixIcon: vm.searchController.text.isNotEmpty
                ? GestureDetector(
              onTap: () {
                vm.searchController.clear();
                vm.onSearchQueryChanged('');
              },
              child: Icon(Icons.close, color: Colors.grey[500], size: 18),
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