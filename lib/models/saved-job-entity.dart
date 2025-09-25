class SavedJobEntity {
  final int savedId;
  final int userId;
  final int jobId;
  final DateTime savedAt;

  SavedJobEntity({
    required this.savedId,
    required this.userId,
    required this.jobId,
    required this.savedAt,
  });

  factory SavedJobEntity.fromJson(Map<String, dynamic> json) => SavedJobEntity(
    savedId: json['saved_id'],
    userId: json['user_id'],
    jobId: json['job_id'],
    savedAt: DateTime.parse(json['saved_at']),
  );

  Map<String, dynamic> toJson() => {
    'saved_id': savedId,
    'user_id': userId,
    'job_id': jobId,
    'saved_at': savedAt.toIso8601String(),
  };
}
