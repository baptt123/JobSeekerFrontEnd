import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/search_view_model.dart';
import '../../../widget/user/search/search_body.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: Consumer<SearchViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: const BackButton(color: Colors.black87),
              titleSpacing: 0,
              title: Container(
                margin: const EdgeInsets.only(right: 16),
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: vm.searchController,
                  focusNode: vm.searchFocusNode,
                  decoration: const InputDecoration(
                    hintText: "Tìm kiếm việc làm, công ty...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: vm.onSearchQueryChanged,
                  onSubmitted: vm.onSearchSubmitted,
                ),
              ),
            ),
            body: Column(
              children: [
                const Divider(height: 1),
                // Chips Filter nhanh
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: ["Gần đây", "Lương cao", "Remote", "Part-time"].map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(filter, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(child: SearchBody(viewModel: vm)),
              ],
            ),
          );
        },
      ),
    );
  }
}