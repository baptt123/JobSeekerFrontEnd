import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  int selectedTab = 0;

  void setSelectedTab(int index) {
    selectedTab = index;
    notifyListeners();
  }
}
