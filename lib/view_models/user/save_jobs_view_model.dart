import 'package:flutter/foundation.dart';

class SavedJobsViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> jobs = [];

  int? selectedJobIndex;

  void addDummyJobs() {
    jobs = [
      {
        'companyLogo': 'google',
        'title': 'UI/UX Designer',
        'company': 'Google inc',
        'location': 'California, USA',
        'tags': ['Design', 'Full time', 'Senior designer'],
        'salary': '\$15K/Mo',
      },
      {
        'companyLogo': 'dribbble',
        'title': 'Lead Designer',
        'company': 'Dribbble inc',
        'location': 'California, USA',
        'tags': ['Design', 'Full time', 'Senior designer'],
        'salary': '\$20K/Mo',
      },
      {
        'companyLogo': 'twitter',
        'title': 'UX Researcher',
        'company': 'Twitter inc',
        'location': 'California, USA',
        'tags': ['Design', 'Full time', 'Senior designer'],
        'salary': '\$12K/Mo',
      },
    ];
    notifyListeners();
  }

  void deleteJob(int idx) {
    jobs.removeAt(idx);
    notifyListeners();
  }

  void deleteAll() {
    jobs.clear();
    notifyListeners();
  }

  void selectJob(int idx) {
    selectedJobIndex = idx;
    notifyListeners();
  }

  void clearSelected() {
    selectedJobIndex = null;
    notifyListeners();
  }
}
