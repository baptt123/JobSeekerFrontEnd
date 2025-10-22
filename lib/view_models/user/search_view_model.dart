// lib/viewmodels/search_view_model.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/models/job-entity.dart';

import '../../services/job_service.dart';

// Enum để quản lý trạng thái UI
enum SearchUIState {
  idle,       // Mới vào, chưa tìm kiếm
  suggesting, // Đang gõ, hiển thị gợi ý
  loading,    // Đang gọi API search-jobs
  success,    // Tải kết quả thành công
  error,      // Tải kết quả thất bại
}

class SearchViewModel extends ChangeNotifier {
  final JobService _jobService = JobService();

  // Controllers
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  // State
  SearchUIState _uiState = SearchUIState.idle;
  List<JobEntity> _searchResults = [];
  List<String> _suggestions = [];
  String _errorMessage = '';

  // Timer để debounce khi gõ phím
  Timer? _debounce;

  // Getters
  SearchUIState get uiState => _uiState;
  List<JobEntity> get searchResults => _searchResults;
  List<String> get suggestions => _suggestions;
  String get errorMessage => _errorMessage;

  SearchViewModel() {
    // Lắng nghe sự kiện focus
    searchFocusNode.addListener(_onFocusChange);
    // Tải một số job mặc định khi mới vào
    executeSearch("flutter developer");
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    searchFocusNode.removeListener(_onFocusChange);
    searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (searchFocusNode.hasFocus && searchController.text.isNotEmpty) {
      // Khi focus vào lại và đang có text, hiển thị lại gợi ý
      _fetchSuggestions(searchController.text);
    } else if (!searchFocusNode.hasFocus) {
      // Khi mất focus, ẩn gợi ý
      _uiState = SearchUIState.success; // Quay về trạng thái hiển thị kết quả
      _suggestions = [];
      notifyListeners();
    }
  }

  /// Được gọi mỗi khi text trong TextField thay đổi
  void onSearchQueryChanged(String query) {
    // Hủy timer cũ nếu có
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      _uiState = SearchUIState.idle;
      _suggestions = [];
      // Có thể xóa kết quả cũ hoặc giữ lại, ở đây tôi giữ lại
      // _searchResults = [];
      notifyListeners();
      return;
    }

    // Đặt timer mới
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(query);
    });
  }

  /// Gọi API lấy gợi ý
  Future<void> _fetchSuggestions(String query) async {
    _uiState = SearchUIState.suggesting;
    notifyListeners();

    _suggestions = await _jobService.suggestJobs(query);
    notifyListeners();
  }

  /// Được gọi khi nhấn nút tìm kiếm trên bàn phím
  void onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      searchFocusNode.unfocus(); // Ẩn bàn phím
      _suggestions = [];
      executeSearch(query);
    }
  }

  /// Được gọi khi nhấn vào một item gợi ý
  void onSuggestionTapped(String suggestion) {
    searchController.text = suggestion;
    searchFocusNode.unfocus(); // Ẩn bàn phím
    _suggestions = [];
    executeSearch(suggestion);
  }

  /// Gọi API /search-jobs
  Future<void> executeSearch(String query) async {
    _uiState = SearchUIState.loading;
    _suggestions = []; // Xóa gợi ý khi bắt đầu tìm kiếm
    notifyListeners();

    try {
      _searchResults = await _jobService.searchJobs(query);
      _uiState = SearchUIState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _uiState = SearchUIState.error;
    }
    notifyListeners();
  }
}