class SkillEntity {
  final int skillId;
  final String skillName;

  SkillEntity({
    required this.skillId,
    required this.skillName,
  });

  factory SkillEntity.fromJson(Map<String, dynamic> json) => SkillEntity(
    skillId: json['skill_id'],
    skillName: json['skill_name'],
  );
}
