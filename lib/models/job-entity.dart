// lib/models/job_entity.dart
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
  final CompanyEntity? company; // Giữ nguyên

  // --- THÊM TRƯỜNG MỚI (Từ DTO) ---
  final List<String> skills;

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
    this.skills = const [], // Mặc định là list rỗng (non-breaking)
  });

  // --- FACTORY CŨ CỦA BẠN (Giữ nguyên) ---
  factory JobEntity.fromJson(Map<String, dynamic> json) {
    return JobEntity(
      jobId: json['job_id'] as int? ?? 0,
      companyId: json['company_id'] as int? ?? 0,
      postedBy: json['posted_by'] as int? ?? 0,
      title: json['title'] as String? ?? 'N/A',
      description: json['description'] as String? ?? 'Không có mô tả',
      requirements: json['requirements'],
      location: json['location'],
      jobType: json['job_type'],
      salaryMin: json['salary_min'] != null
          ? double.tryParse(json['salary_min'].toString())
          : null,
      salaryMax: json['salary_max'] != null
          ? double.tryParse(json['salary_max'].toString())
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      company: json['company'] != null
          ? CompanyEntity.fromJson(json['company'])
          : null,
      // skills sẽ dùng giá trị mặc định là list rỗng
    );
  }

  // --- FACTORY MỚI (Để đọc JSON phẳng từ API) ---
  factory JobEntity.fromFlatJson(Map<String, dynamic> json) {
    // 1. Đọc các trường phẳng từ DTO
    final companyName = json['company_name'] as String?;
    final logoUrl = json['logo_url'] as String?; // Tên trong DTO là 'logo_url'

    // 2. "Tái tạo" (re-hydrate) đối tượng CompanyEntity
    CompanyEntity? companyInstance;
    if (companyName != null) {
      companyInstance = CompanyEntity(
        companyId: 0, // Chúng ta không có ID từ JSON phẳng, dùng tạm 0
        name: companyName,
        logoUrl: logoUrl,
        createdAt: DateTime.now(), // Không có, dùng tạm
        // Các trường khác (description, website...) sẽ là null
      );
    }

    // 3. Đọc skills
    final skillsList = (json['skills'] as List<dynamic>?)
        ?.map((e) => e.toString())
        ?.toList() ??
        <String>[];

    // 4. Trả về JobEntity
    return JobEntity(
      jobId: json['job_id'] as int? ?? 0,
      companyId: 0, // Không có, dùng tạm 0
      postedBy: 0,  // Không có, dùng tạm 0
      title: json['title'] as String? ?? 'N/A',
      description: json['description'] as String? ?? 'Không có mô tả',
      requirements: json['requirements'],
      location: json['location'],
      jobType: json['job_type'],
      salaryMin: json['salary_min'] != null
          ? double.tryParse(json['salary_min'].toString())
          : null,
      salaryMax: json['salary_max'] != null
          ? double.tryParse(json['salary_max'].toString())
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),

      // Gán đối tượng company vừa "tái tạo"
      company: companyInstance,
      // Gán skills
      skills: skillsList,
    );
  }
}