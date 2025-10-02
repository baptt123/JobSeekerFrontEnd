import 'package:flutter/material.dart';

import '../../services/job_service.dart';

class JobSearchViewModel extends ChangeNotifier {
  final JobService _service = JobService();

  List<dynamic> jobs = [];
  List<String> suggestions = [];
  bool loading = false;

  Future<void> search(String query) async {
    loading = true;
    notifyListeners();

    jobs = await JobService.searchJobs(query);
    loading = false;
    notifyListeners();
  }

  Future<void> suggest(String query) async {
    if (query.isEmpty) {
      suggestions = [];
      notifyListeners();
      return;
    }

    suggestions = await JobService.suggestJobs(query);
    notifyListeners();
  }
}
