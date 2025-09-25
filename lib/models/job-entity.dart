class JobEntity {
  final int jobId;
  final int companyId;
  final int postedBy;
  final String title;
  final String description;
  final String? requirements;
  final double? salaryMin;
  final double? salaryMax;
  final String? location;
  final String? jobType;
  final DateTime createdAt;

  JobEntity({
    required this.jobId,
    required this.companyId,
    required this.postedBy,
    required this.title,
    required this.description,
    this.requirements,
    this.salaryMin,
    this.salaryMax,
    this.location,
    this.jobType,
    required this.createdAt,
  });

  factory JobEntity.fromJson(Map<String, dynamic> json) => JobEntity(
    jobId: json['job_id'],
    companyId: json['company_id'],
    postedBy: json['posted_by'],
    title: json['title'],
    description: json['description'],
    requirements: json['requirements'],
    salaryMin: (json['salary_min'] as num?)?.toDouble(),
    salaryMax: (json['salary_max'] as num?)?.toDouble(),
    location: json['location'],
    jobType: json['job_type'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'job_id': jobId,
    'company_id': companyId,
    'posted_by': postedBy,
    'title': title,
    'description': description,
    'requirements': requirements,
    'salary_min': salaryMin,
    'salary_max': salaryMax,
    'location': location,
    'job_type': jobType,
    'created_at': createdAt.toIso8601String(),
  };
}
