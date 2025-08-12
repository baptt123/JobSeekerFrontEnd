import 'package:flutter/material.dart';

class NotificationsViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> notifications = [
    // example: {'icon':'assets/google.png', 'title':'Application sent', 'subtitle':'Applications for Google companies have...', 'time': '25min ago'}
  ];

  void deleteNotification(int index) {
    notifications.removeAt(index);
    notifyListeners();
  }
}
