import 'education_dto.dart';
import 'experience_dto.dart';
import 'skill_dto.dart';
import 'project_dto.dart'; // Import mới
import 'achievement_dto.dart'; // Import mới

class CreateCvDto {
  final String fullName;
  final String? avatarUrl;
  final String jobTitle;
  final String email;
  final String phone;
  final String address;
  final String summary;
  final List<ExperienceDto> experiences;
  final List<EducationDto> educations;
  final List<SkillDto> skills;
  final List<ProjectDto> projects; // Field mới
  final List<AchievementDto> achievements; // Field mới

  CreateCvDto({
    required this.fullName,
    this.avatarUrl,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.address,
    required this.summary,
    required this.experiences,
    required this.educations,
    required this.skills,
    this.projects = const [],
    this.achievements = const [],
  });

  // Factory và toJson cập nhật tương ứng
  factory CreateCvDto.fromJson(Map<String, dynamic> json) {
    return CreateCvDto(
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'],
      jobTitle: json['jobTitle'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      summary: json['summary'] ?? '',
      experiences: (json['experiences'] as List?)
          ?.map((e) => ExperienceDto.fromJson(e))
          .toList() ?? [],
      educations: (json['educations'] as List?)
          ?.map((e) => EducationDto.fromJson(e))
          .toList() ?? [],
      skills: (json['skills'] as List?)
          ?.map((e) => SkillDto.fromJson(e))
          .toList() ?? [],
      projects: (json['projects'] as List?)
          ?.map((e) => ProjectDto.fromJson(e))
          .toList() ?? [],
      achievements: (json['achievements'] as List?)
          ?.map((e) => AchievementDto.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'avatarUrl': avatarUrl,
    'jobTitle': jobTitle,
    'email': email,
    'phone': phone,
    'address': address,
    'summary': summary,
    'experiences': experiences.map((e) => e.toJson()).toList(),
    'educations': educations.map((e) => e.toJson()).toList(),
    'skills': skills.map((e) => e.toJson()).toList(),
    'projects': projects.map((e) => e.toJson()).toList(),
    'achievements': achievements.map((e) => e.toJson()).toList(),
  };
}