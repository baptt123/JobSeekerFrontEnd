import 'company-entity.dart';

// Class chứa thông tin nhà tuyển dụng
class RecruiterInfo {
  final int id;
  final String fullName;
  final String? avatarUrl;
  final String? email;

  RecruiterInfo({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.email,
  });

  factory RecruiterInfo.fromJson(Map<String, dynamic> json) {
    return RecruiterInfo(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? 'Nhà tuyển dụng',
      avatarUrl: json['avatar_url'],
      email: json['email'],
    );
  }
}

class JobEntity {
  final int jobId;
  final String title;
  final String? description;
  final String? requirements;
  final double? salaryMin;
  final double? salaryMax;
  final String? location;
  final String? jobType;
  final bool isApplied;
  final bool isSaved;
  final CompanyEntity? company;
  final DateTime? deadline;
  final List<String> skills;

  // [UPDATE] Thêm trường recruiter
  final RecruiterInfo? recruiter;

  JobEntity({
    required this.jobId,
    required this.title,
    this.description,
    this.requirements,
    this.salaryMin,
    this.salaryMax,
    this.location,
    this.jobType,
    required this.isApplied,
    required this.isSaved,
    this.company,
    this.skills = const [],
    this.deadline,
    this.recruiter, // [UPDATE] Constructor
  });

  factory JobEntity.fromJson(Map<String, dynamic> json) {
    double? parseDoubleSafe(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    final skillsList = (json['skills'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ??
        <String>[];

    return JobEntity(
      jobId: json['job_id'] as int? ?? 0,
      title: json['title'] as String? ?? 'N/A',
      description: json['description'] as String?,
      requirements: json['requirements'] as String?,
      salaryMin: parseDoubleSafe(json['salary_min']),
      salaryMax: parseDoubleSafe(json['salary_max']),
      location: json['location'] as String?,
      jobType: json['job_type'] as String?,
      isApplied: json['isApplied'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      company: json['company'] != null && json['company'] is Map
          ? CompanyEntity.fromJson(json['company'] as Map<String, dynamic>)
          : null,
      skills: skillsList,

      // [UPDATE] Parse recruiter info từ field 'postedBy' do backend trả về
      recruiter: json['postedBy'] != null
          ? RecruiterInfo.fromJson(json['postedBy'])
          : null,
    );
  }

  factory JobEntity.fromFlatJson(Map<String, dynamic> json) {
    double? parseDoubleSafe(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    final companyName = json['company_name'] as String?;
    final logoUrl = json['logo_url'] as String?;
    final int companyId = json['company_id'] as int? ?? 0;

    CompanyEntity? companyInstance;
    if (companyName != null) {
      companyInstance = CompanyEntity(
        companyId: companyId,
        name: companyName,
        logoUrl: logoUrl,
      );
    }

    final skillsList = (json['skills'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ??
        <String>[];

    return JobEntity(
      jobId: json['job_id'] as int? ?? 0,
      title: json['title'] as String? ?? 'N/A',
      description: json['description'] as String?,
      requirements: json['requirements'] as String?,
      location: json['location'] as String?,
      jobType: json['job_type'] as String?,
      salaryMin: parseDoubleSafe(json['salary_min']),
      salaryMax: parseDoubleSafe(json['salary_max']),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      company: companyInstance,
      skills: skillsList,
      isApplied: json['isApplied'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      // fromFlatJson thường dùng cho list, có thể không cần recruiter info ngay
      recruiter: null,
    );
  }
}