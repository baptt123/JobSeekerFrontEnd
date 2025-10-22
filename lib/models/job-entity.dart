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

  factory JobEntity.fromJson(Map<String, dynamic> json) {
    return JobEntity(
      // Các trường đã sửa ở lần trước (an toàn với null)
      jobId: json['job_id'] as int? ?? 0,
      companyId: json['company_id'] as int? ?? 0,
      postedBy: json['posted_by'] as int? ?? 0,
      title: json['title'] as String? ?? 'N/A',
      description: json['description'] as String? ?? 'Không có mô tả',

      // Các trường nullable
      requirements: json['requirements'],
      location: json['location'],
      jobType: json['job_type'],

      // === SỬA LỖI Ở ĐÂY ===
      // Chuyển từ 'as num?' sang 'as String?' và dùng 'double.tryParse'
      salaryMin: json['salary_min'] != null
          ? double.tryParse(json['salary_min'].toString())
          : null,
      salaryMax: json['salary_max'] != null
          ? double.tryParse(json['salary_max'].toString())
          : null,

      // Trường
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      company: json['company'] != null
          ? CompanyEntity.fromJson(json['company'])
          : null,
    );
  }
}
