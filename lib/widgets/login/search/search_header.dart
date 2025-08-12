// lib/screens/search/widgets/search_header.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/search_view_model.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

    // Vì TextEditingController mới mỗi build, bạn có thể tùy chọn quản lý khác.
    final searchController = TextEditingController(text: vm.searchTerm);
    final locationController = TextEditingController(text: vm.location);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4B3DFE), Color(0xFF181340)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_back, color: Colors.white),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Job title or keyword',
                      ),
                      onChanged: (value) => vm.setSearchTerm(value),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.location_on, color: Colors.deepOrange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Location',
                      ),
                      onChanged: (value) => vm.setLocation(value),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
