class SavedJobEntity {
  final int userId;
  final int jobId;
  final DateTime savedAt;

  SavedJobEntity({
    required this.userId,
    required this.jobId,
    required this.savedAt,
  });

  factory SavedJobEntity.fromJson(Map<String, dynamic> json) => SavedJobEntity(
    userId: json['user_id'],
    jobId: json['job_id'],
    savedAt: DateTime.parse(json['saved_at']),
  );
}
