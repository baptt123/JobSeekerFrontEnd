import 'package:flutter/material.dart';

class JobApplicationProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _applications = [
    {
      'id': 1,
      'job': {'title': 'Backend Developer', 'description': 'Xây dựng API bằng NestJS'},
      'user': {'fullName': 'Nguyen Van A', 'email': 'a@gmail.com', 'avatarUrl': 'https://i.pravatar.cc/150?img=3'},
      'status': 'Applied',
      'coverLetter': 'Em rất phù hợp với công việc này!',
    },
    {
      'id': 2,
      'job': {'title': 'Frontend Developer', 'description': 'React/Flutter'},
      'user': {'fullName': 'Tran Thi B', 'email': 'b@gmail.com', 'avatarUrl': 'https://i.pravatar.cc/150?img=5'},
      'status': 'Screening',
      'coverLetter': '',
    },
  ];

  List<Map<String, dynamic>> get applications => List.unmodifiable(_applications);

  void acceptApplication(int id) {
    final index = _applications.indexWhere((app) => app['id'] == id);
    if (index != -1) {
      _applications[index]['status'] = 'Accepted';
      notifyListeners();
    }
  }
}
