import 'company-entity.dart';

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
  final CompanyEntity? company; // thêm quan hệ

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
    this.company,
  });

  factory JobEntity.fromJson(Map<String, dynamic> json) => JobEntity(
    jobId: json['job_id'],
    companyId: json['company_id'],
    postedBy: json['posted_by'],
    title: json['title'],
    description: json['description'],
    requirements: json['requirements'],
    salaryMin: json['salary_min'] != null
        ? double.tryParse(json['salary_min'].toString())
        : null,
    salaryMax: json['salary_max'] != null
        ? double.tryParse(json['salary_max'].toString())
        : null,
    location: json['location'],
    jobType: json['job_type'],
    createdAt: DateTime.parse(json['created_at']),
    company: json['company'] != null
        ? CompanyEntity.fromJson(json['company'])
        : null,
  );
}
