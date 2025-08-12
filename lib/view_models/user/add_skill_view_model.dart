import 'package:flutter/material.dart';

// Không cần model, chỉ quản lý tìm kiếm và skills đã chọn
class AddSkillViewModel extends ChangeNotifier {
  String searchTerm = '';
  Set<String> selectedSkills = {};

  // Demo skills
  final List<String> allSkills = [
    "Graphic Design", "Graphic Thinking", "Ui/UX Design",
    "Adobe Indesign", "Web Design", "InDesign",
    "Canva Design", "User Interface Design",
    "Product Design", "User Experience Design",
  ];

  void setSearchTerm(String term) {
    searchTerm = term;
    notifyListeners();
  }

  void toggleSkill(String skill) {
    if (selectedSkills.contains(skill))
      selectedSkills.remove(skill);
    else
      selectedSkills.add(skill);
    notifyListeners();
  }

  List<String> get filteredSkills {
    if (searchTerm.isEmpty) return allSkills;
    return allSkills.where((s) => s.toLowerCase().contains(searchTerm.toLowerCase())).toList();
  }
}
