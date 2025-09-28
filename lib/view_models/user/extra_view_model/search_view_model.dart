// lib/screens/search/search_viewmodel.dart
import 'package:flutter/material.dart';

class SearchViewModel extends ChangeNotifier {
  String _searchTerm = '';
  String _location = '';

  String get searchTerm => _searchTerm;
  String get location => _location;

  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  void setLocation(String loc) {
    _location = loc;
    notifyListeners();
  }

// Sau này bạn có thể thêm lọc công việc, API load, ...
}
