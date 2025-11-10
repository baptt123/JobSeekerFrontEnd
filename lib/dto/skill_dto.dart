class SkillDto {
  final String name;
  SkillDto({required this.name});
  Map<String, dynamic> toJson() => {'name': name};
}