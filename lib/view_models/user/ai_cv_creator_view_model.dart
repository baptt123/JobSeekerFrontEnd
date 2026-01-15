import 'package:flutter/material.dart';
import '../../dto/create_cv_dto.dart';
import '../../dto/education_dto.dart';
import '../../dto/experience_dto.dart';
import '../../dto/skill_dto.dart';
import '../../services/ai_cv_generator_service.dart';

class AiCvCreatorViewModel extends ChangeNotifier {
  final AiCvGeneratorService _aiService = AiCvGeneratorService();

  // Khởi tạo mặc định, thêm avatarUrl là ảnh ngẫu nhiên từ mạng
  CreateCvDto _cvData = CreateCvDto(
      fullName: "",
      avatarUrl: "https://i.pravatar.cc/300", // Link ảnh tạm
      jobTitle: "",
      email: "",
      phone: "",
      address: "",
      summary: "",
      experiences: [],
      educations: [],
      skills: []
  );

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedTemplate = 'modern';

  CreateCvDto get cvData => _cvData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedTemplate => _selectedTemplate;

  void changeTemplate(String templateId) {
    _selectedTemplate = templateId;
    notifyListeners();
  }

  // Tạo bằng AI (Gemini)
  Future<void> generateFromPrompt(String prompt) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final generated = await _aiService.generateCvFromPrompt(prompt);
      // Giữ lại avatarUrl mặc định nếu AI không trả về (thường AI text không trả về ảnh)
      _cvData = CreateCvDto(
        fullName: generated.fullName,
        avatarUrl: _cvData.avatarUrl,
        jobTitle: generated.jobTitle,
        email: generated.email,
        phone: generated.phone,
        address: generated.address,
        summary: generated.summary,
        experiences: generated.experiences,
        educations: generated.educations,
        skills: generated.skills,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cập nhật các trường text cơ bản
  void updateField({
    String? fullName, String? jobTitle, String? email,
    String? phone, String? address, String? summary
  }) {
    _cvData = CreateCvDto(
      fullName: fullName ?? _cvData.fullName,
      avatarUrl: _cvData.avatarUrl,
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

  // --- Logic Kỹ năng ---
  void addSkill(String name) {
    List<SkillDto> current = List.from(_cvData.skills);
    current.add(SkillDto(name: name));
    _updateLists(skills: current);
  }

  void removeSkill(int index) {
    List<SkillDto> current = List.from(_cvData.skills);
    current.removeAt(index);
    _updateLists(skills: current);
  }

  // --- Logic Học vấn (Mới) ---
  void addEducation(EducationDto edu) {
    List<EducationDto> current = List.from(_cvData.educations);
    current.add(edu);
    _updateLists(educations: current);
  }

  void removeEducation(int index) {
    List<EducationDto> current = List.from(_cvData.educations);
    current.removeAt(index);
    _updateLists(educations: current);
  }

  // Hàm helper private để update list
  void _updateLists({
    List<ExperienceDto>? experiences,
    List<EducationDto>? educations,
    List<SkillDto>? skills,
  }) {
    _cvData = CreateCvDto(
        fullName: _cvData.fullName,
        avatarUrl: _cvData.avatarUrl,
        jobTitle: _cvData.jobTitle,
        email: _cvData.email,
        phone: _cvData.phone,
        address: _cvData.address,
        summary: _cvData.summary,
        experiences: experiences ?? _cvData.experiences,
        educations: educations ?? _cvData.educations,
        skills: skills ?? _cvData.skills
    );
    notifyListeners();
  }
}