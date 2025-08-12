import 'package:flutter/material.dart';

class FilterViewModel extends ChangeNotifier {
  String lastUpdate = 'Any time';
  String workplaceType = 'On-site';
  String jobType = 'Full time';
  String positionLevel = 'Senior';
  Set<String> cities = {'California, USA'};
  double salaryMin = 19;
  double salaryMax = 25;
  String experience = '6-10 years';
  Set<String> specialization = {'Design', 'Programmer'};

  void setLastUpdate(String value) {
    lastUpdate = value;
    notifyListeners();
  }
  void setWorkplaceType(String value) {
    workplaceType = value;
    notifyListeners();
  }
  void setJobType(String value) {
    jobType = value;
    notifyListeners();
  }
  void setPositionLevel(String value) {
    positionLevel = value;
    notifyListeners();
  }
  void toggleCity(String city) {
    if (cities.contains(city)) cities.remove(city);
    else cities.add(city);
    notifyListeners();
  }
  void setSalaryRange(double min, double max) {
    salaryMin = min;
    salaryMax = max;
    notifyListeners();
  }
  void setExperience(String value) {
    experience = value;
    notifyListeners();
  }
  void toggleSpecialization(String sp) {
    if (specialization.contains(sp)) specialization.remove(sp);
    else specialization.add(sp);
    notifyListeners();
  }

  void reset() {
    lastUpdate = 'Any time';
    workplaceType = 'On-site';
    jobType = 'Full time';
    positionLevel = 'Senior';
    cities = {};
    salaryMin = 19;
    salaryMax = 25;
    experience = '';
    specialization = {};
    notifyListeners();
  }
}
