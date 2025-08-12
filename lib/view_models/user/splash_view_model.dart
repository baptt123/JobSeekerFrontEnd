import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  bool _isCompleted = false;

  bool get isCompleted => _isCompleted;

  void completeSplash() {
    _isCompleted = true;
    notifyListeners();
  }
}
