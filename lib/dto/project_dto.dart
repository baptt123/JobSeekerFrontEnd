class ProjectDto {
  final String name;
  final String role;
  final String description;
  final String link;

  ProjectDto({
    required this.name,
    this.role = '',
    this.description = '',
    this.link = '',
  });

  factory ProjectDto.fromJson(Map<String, dynamic> json) {
    return ProjectDto(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'role': role,
    'description': description,
    'link': link,
  };
}