class EducationDto {
  final String school;
  final String degree;
  final String duration;

  EducationDto({
    required this.school,
    required this.degree,
    required this.duration,
  });

  // --- Bổ sung fromJson ---
  factory EducationDto.fromJson(Map<String, dynamic> json) {
    return EducationDto(
      school: json['school'] ?? '',
      degree: json['degree'] ?? '',
      duration: json['duration'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'school': school,
    'degree': degree,
    'duration': duration,
  };
}