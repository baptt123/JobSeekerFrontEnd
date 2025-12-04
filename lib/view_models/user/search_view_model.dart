// lib/view_models/user/search_view_model.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/models/job-entity.dart';
import '../../services/job_service.dart';

enum SearchUIState { idle, suggesting, loading, success, error }

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

  Timer? _debounce;

  // Getters
  SearchUIState get uiState => _uiState;
  List<JobEntity> get searchResults => _searchResults;
  List<String> get suggestions => _suggestions;
  String get errorMessage => _errorMessage;

  SearchViewModel() {
    searchFocusNode.addListener(_onFocusChange);
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
      _fetchSuggestions(searchController.text);
    } else if (!searchFocusNode.hasFocus) {
      // Khi mất focus, nếu có kết quả tìm kiếm thì hiển thị, không thì thôi
      if (_searchResults.isNotEmpty) {
        _uiState = SearchUIState.success;
      }
      notifyListeners();
    }
  }

  void onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      _uiState = SearchUIState.idle;
      _suggestions = [];
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    _uiState = SearchUIState.suggesting;
    notifyListeners();
    try {
      _suggestions = await _jobService.suggestJobs(query);
    } catch (_) {
      _suggestions = [];
    }
    notifyListeners();
  }

  void onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      searchFocusNode.unfocus();
      _suggestions = [];
      executeSearch(query);
    }
  }

  void onSuggestionTapped(String suggestion) {
    searchController.text = suggestion;
    searchFocusNode.unfocus();
    _suggestions = [];
    executeSearch(suggestion);
  }

  // Hàm thực thi tìm kiếm
  Future<void> executeSearch(String query) async {
    _uiState = SearchUIState.loading;
    _suggestions = [];
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