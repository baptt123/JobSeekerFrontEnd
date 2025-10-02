class JobApplicationEntity {
  final int applicationId;
  final int jobId;
  final int userId;
  final int? cvId;
  final String? coverLetter;
  final String status;
  final DateTime appliedAt;

  JobApplicationEntity({
    required this.applicationId,
    required this.jobId,
    required this.userId,
    this.cvId,
    this.coverLetter,
    required this.status,
    required this.appliedAt,
  });

  factory JobApplicationEntity.fromJson(Map<String, dynamic> json) => JobApplicationEntity(
    applicationId: json['application_id'],
    jobId: json['job_id'],
    userId: json['user_id'],
    cvId: json['cv_id'],
    coverLetter: json['cover_letter'],
    status: json['status'],
    appliedAt: DateTime.parse(json['applied_at']),
  );
}
