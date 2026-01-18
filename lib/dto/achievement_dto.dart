class AchievementDto {
  final String name;
  final String description;

  AchievementDto({required this.name, this.description = ''});

  factory AchievementDto.fromJson(Map<String, dynamic> json) {
    return AchievementDto(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
  };
}