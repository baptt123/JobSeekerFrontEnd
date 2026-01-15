// lib/dto/create_cv_dto.dart
import 'education_dto.dart';
import 'experience_dto.dart';
import 'skill_dto.dart';

class CreateCvDto {
  final String fullName;
  final String? avatarUrl; // Thêm trường này
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

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'avatarUrl': avatarUrl, // Gửi lên backend
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