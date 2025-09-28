import 'package:flutter/material.dart';

class RecruiterDashboardViewModel extends ChangeNotifier {
  int myJobs = 3;
  int applicants = 12;

  void createJobPosting() {
    // Tăng số lượng bài đăng, demo thôi
    myJobs++;
    notifyListeners();
  }
}
