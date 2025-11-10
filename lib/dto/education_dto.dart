class EducationDto {
  final String school;
  final String degree;
  final String duration;

  EducationDto({
    required this.school,
    required this.degree,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
    'school': school,
    'degree': degree,
    'duration': duration,
  };
}