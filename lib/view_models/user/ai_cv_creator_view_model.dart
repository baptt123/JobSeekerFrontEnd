import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import '../../dto/create_cv_dto.dart';
import '../../dto/education_dto.dart';
import '../../dto/experience_dto.dart';
import '../../dto/skill_dto.dart';
import '../../dto/project_dto.dart';      // Import DTO Dự án
import '../../dto/achievement_dto.dart';  // Import DTO Thành tích
import '../../services/ai_cv_generator_service.dart';

class AiCvCreatorViewModel extends ChangeNotifier {
  final AiCvGeneratorService _aiService = AiCvGeneratorService();

  // State quản lý ảnh
  File? _localImage;
  File? get localImage => _localImage;

  CreateCvDto _cvData = CreateCvDto(
      fullName: "",
      avatarUrl: "",
      jobTitle: "",
      email: "",
      phone: "",
      address: "",
      summary: "",
      experiences: [],
      educations: [],
      skills: [],
      projects: [],      // Init list rỗng
      achievements: []   // Init list rỗng
  );

  bool _isLoading = false;
  String? _errorMessage;
  String _selectedTemplate = 'modern';

  CreateCvDto get cvData => _cvData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedTemplate => _selectedTemplate;

  // --- Logic Ảnh (MỚI) ---
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _localImage = File(image.path);
      notifyListeners();
    }
  }

  void removeImage() {
    _localImage = null;
    notifyListeners();
  }

  void changeTemplate(String templateId) {
    _selectedTemplate = templateId;
    notifyListeners();
  }

  Future<void> generateFromPrompt(String prompt) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final generated = await _aiService.generateCvFromPrompt(prompt);
      _cvData = CreateCvDto(
        fullName: generated.fullName,
        avatarUrl: _cvData.avatarUrl, // Giữ URL cũ nếu có
        jobTitle: generated.jobTitle,
        email: generated.email,
        phone: generated.phone,
        address: generated.address,
        summary: generated.summary,
        experiences: generated.experiences,
        educations: generated.educations,
        skills: generated.skills,
        projects: generated.projects,          // AI tạo dự án
        achievements: generated.achievements,  // AI tạo thành tích
      );
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
      avatarUrl: _cvData.avatarUrl,
      jobTitle: jobTitle ?? _cvData.jobTitle,
      email: email ?? _cvData.email,
      phone: phone ?? _cvData.phone,
      address: address ?? _cvData.address,
      summary: summary ?? _cvData.summary,
      experiences: _cvData.experiences,
      educations: _cvData.educations,
      skills: _cvData.skills,
      projects: _cvData.projects,
      achievements: _cvData.achievements,
    );
    notifyListeners();
  }

  // --- Logic List (Update chung) ---
  void _updateLists({
    List<ExperienceDto>? experiences,
    List<EducationDto>? educations,
    List<SkillDto>? skills,
    List<ProjectDto>? projects,
    List<AchievementDto>? achievements,
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
        skills: skills ?? _cvData.skills,
        projects: projects ?? _cvData.projects,
        achievements: achievements ?? _cvData.achievements
    );
    notifyListeners();
  }

  // Kỹ năng
  void addSkill(String name) => _updateLists(skills: [..._cvData.skills, SkillDto(name: name)]);
  void removeSkill(int index) {
    var list = List<SkillDto>.from(_cvData.skills)..removeAt(index);
    _updateLists(skills: list);
  }

  // Học vấn
  void addEducation(EducationDto item) => _updateLists(educations: [..._cvData.educations, item]);
  void removeEducation(int index) {
    var list = List<EducationDto>.from(_cvData.educations)..removeAt(index);
    _updateLists(educations: list);
  }

  // Kinh nghiệm
  void addExperience(ExperienceDto item) => _updateLists(experiences: [..._cvData.experiences, item]);
  void removeExperience(int index) {
    var list = List<ExperienceDto>.from(_cvData.experiences)..removeAt(index);
    _updateLists(experiences: list);
  }

  // Dự án (MỚI)
  void addProject(ProjectDto item) => _updateLists(projects: [..._cvData.projects, item]);
  void removeProject(int index) {
    var list = List<ProjectDto>.from(_cvData.projects)..removeAt(index);
    _updateLists(projects: list);
  }

  // Thành tích (MỚI)
  void addAchievement(AchievementDto item) => _updateLists(achievements: [..._cvData.achievements, item]);
  void removeAchievement(int index) {
    var list = List<AchievementDto>.from(_cvData.achievements)..removeAt(index);
    _updateLists(achievements: list);
  }
}