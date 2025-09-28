import 'package:flutter/material.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  int totalUsers = 200;
  int totalJobs = 75;

  void loadData() {
    // Logic fake, chỉ để reload state
    totalUsers++;
    totalJobs += 2;
    notifyListeners();
  }
}
