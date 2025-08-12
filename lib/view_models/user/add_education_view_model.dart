import 'package:flutter/material.dart';

class AddEducationViewModel extends ChangeNotifier {
  String levelOfEducation = '';
  String institutionName = '';
  String fieldOfStudy = '';
  DateTime? startDate;
  DateTime? endDate;
  bool isCurrent = false;
  String description = '';

  void updateLevel(String value) {
    levelOfEducation = value;
    notifyListeners();
  }
  void updateInstitution(String value) {
    institutionName = value;
    notifyListeners();
  }
  void updateField(String value) {
    fieldOfStudy = value;
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
