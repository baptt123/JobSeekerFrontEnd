class SkillDto {
  final String name;

  SkillDto({required this.name});

  // --- Bổ sung fromJson ---
  factory SkillDto.fromJson(Map<String, dynamic> json) {
    return SkillDto(
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name};
}