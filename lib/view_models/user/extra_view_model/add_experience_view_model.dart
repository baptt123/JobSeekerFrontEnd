import 'package:flutter/material.dart';

class AddExperienceViewModel extends ChangeNotifier {
  String jobTitle = '';
  String company = '';
  DateTime? startDate;
  DateTime? endDate;
  bool isCurrent = false;
  String description = '';

  void updateJobTitle(String value) {
    jobTitle = value;
    notifyListeners();
  }
  void updateCompany(String value) {
    company = value;
    notifyListeners();
  }
  void updateStartDate(DateTime value) {
    startDate = value;
    notifyListeners();
  }
  void updateEndDate(DateTime value) {
    endDate = value;
    notifyListeners();
  }
  void updateIsCurrent(bool value) {
    isCurrent = value;
    notifyListeners();
  }
  void updateDescription(String value) {
    description = value;
    notifyListeners();
  }

  void save() {
    // Gọi API, lưu dữ liệu ...
  }
}
