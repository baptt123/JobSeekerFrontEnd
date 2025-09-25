class JobSkillEntity {
  final int id;
  final int jobId;
  final int skillId;

  JobSkillEntity({
    required this.id,
    required this.jobId,
    required this.skillId,
  });

  factory JobSkillEntity.fromJson(Map<String, dynamic> json) => JobSkillEntity(
    id: json['id'],
    jobId: json['job_id'],
    skillId: json['skill_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'job_id': jobId,
    'skill_id': skillId,
  };
}
