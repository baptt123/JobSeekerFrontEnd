// view_models/job_view_model.dart
import 'package:flutter/material.dart';

import '../../models/job-entity.dart';
import '../../services/job_service.dart';

class JobViewModel extends ChangeNotifier {
  List<JobEntity> jobs = [];
  bool loading = false;

  Future<void> loadRecommendedJobs() async {
    loading = true;
    notifyListeners();

    try {
      jobs = await JobService.fetchRecommendedJobs();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
