// lib/dto/create_cv_dto.dart
import 'education_dto.dart';
import 'experience_dto.dart';
import 'skill_dto.dart';

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
  });

  // --- PHẦN BỔ SUNG: Factory constructor để convert từ JSON sang Object ---
  factory CreateCvDto.fromJson(Map<String, dynamic> json) {
    return CreateCvDto(
      fullName: json['fullName'] ?? '',
      avatarUrl: json['avatarUrl'],
      jobTitle: json['jobTitle'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      summary: json['summary'] ?? '',
      // Xử lý mapping cho các danh sách lồng nhau (Nested Lists)
      experiences: (json['experiences'] as List<dynamic>?)
          ?.map((e) => ExperienceDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      educations: (json['educations'] as List<dynamic>?)
          ?.map((e) => EducationDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      skills: (json['skills'] as List<dynamic>?)
          ?.map((e) => SkillDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  // --- Phần toJson giữ nguyên ---
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
  };
}