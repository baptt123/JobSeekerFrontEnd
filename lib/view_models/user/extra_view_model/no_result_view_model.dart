// lib/view_models/no_results_view_model.dart
import 'package:flutter/material.dart';

class NoResultsViewModel extends ChangeNotifier {
  String query = '';

  void updateQuery(String val) {
    query = val;
    notifyListeners();
  }
}
