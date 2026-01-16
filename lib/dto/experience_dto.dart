class ExperienceDto {
  final String jobTitle;
  final String company;
  final String duration;
  final String description;

  ExperienceDto({
    required this.jobTitle,
    required this.company,
    required this.duration,
    required this.description,
  });

  // --- Bổ sung fromJson ---
  factory ExperienceDto.fromJson(Map<String, dynamic> json) {
    return ExperienceDto(
      jobTitle: json['jobTitle'] ?? '',
      company: json['company'] ?? '',
      duration: json['duration'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'jobTitle': jobTitle,
    'company': company,
    'duration': duration,
    'description': description,
  };
}