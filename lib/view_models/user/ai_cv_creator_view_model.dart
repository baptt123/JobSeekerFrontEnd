import 'package:flutter/material.dart';
import '../../dto/create_cv_dto.dart';
import '../../dto/education_dto.dart';
import '../../dto/experience_dto.dart';
import '../../dto/skill_dto.dart';
import '../../services/ai_cv_generator_service.dart';

class AiCvCreatorViewModel extends ChangeNotifier {
  final AiCvGeneratorService _aiService = AiCvGeneratorService();

  CreateCvDto _cvData = CreateCvDto(
      fullName: "", jobTitle: "", email: "", phone: "", address: "", summary: "",
      experiences: [], educations: [], skills: []
  );

  bool _isLoading = false;
  String? _errorMessage;

  // Thêm biến quản lý Template
  String _selectedTemplate = 'modern';

  CreateCvDto get cvData => _cvData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedTemplate => _selectedTemplate;

  // Hàm đổi template
  void changeTemplate(String templateId) {
    _selectedTemplate = templateId;
    notifyListeners();
  }

  Future<void> generateFromPrompt(String prompt) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cvData = await _aiService.generateCvFromPrompt(prompt);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateField({
    String? fullName, String? jobTitle, String? email,
    String? phone, String? address, String? summary
  }) {
    _cvData = CreateCvDto(
      fullName: fullName ?? _cvData.fullName,
      jobTitle: jobTitle ?? _cvData.jobTitle,
      email: email ?? _cvData.email,
      phone: phone ?? _cvData.phone,
      address: address ?? _cvData.address,
      summary: summary ?? _cvData.summary,
      experiences: _cvData.experiences,
      educations: _cvData.educations,
      skills: _cvData.skills,
    );
    notifyListeners();
  }

  void addSkill(String name) {
    List<SkillDto> current = List.from(_cvData.skills);
    current.add(SkillDto(name: name));
    _cvData = CreateCvDto(
        fullName: _cvData.fullName, jobTitle: _cvData.jobTitle, email: _cvData.email,
        phone: _cvData.phone, address: _cvData.address, summary: _cvData.summary,
        experiences: _cvData.experiences, educations: _cvData.educations, skills: current
    );
    notifyListeners();
  }
}