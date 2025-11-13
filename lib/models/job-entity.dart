// lib/models/job_entity.dart
// (Cập nhật với fromFlatJson và skills)

import 'company-entity.dart'; // Đảm bảo bạn có file này

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

  // ⭐️ THÊM LẠI TRƯỜNG SKILLS (Vì fromFlatJson cần nó)
  final List<String> skills;

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
    this.skills = const [], // ⭐️ Khởi tạo mặc định
  });

  // --- FACTORY CŨ (Để đọc JSON lồng nhau từ API chi tiết) ---
  factory JobEntity.fromJson(Map<String, dynamic> json) {
    // Helper để parse double một cách an toàn
    double? parseDoubleSafe(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // ⭐️ Xử lý skills (nếu có)
    final skillsList = (json['skills'] as List<dynamic>?)
        ?.map((e) => e.toString())
        ?.toList() ??
        <String>[];

    return JobEntity(
      jobId: json['job_id'] as int? ?? 0, // An toàn hơn
      title: json['title'] as String? ?? 'N/A', // An toàn hơn
      description: json['description'] as String?,
      requirements: json['requirements'] as String?,
      salaryMin: parseDoubleSafe(json['salary_min']),
      salaryMax: parseDoubleSafe(json['salary_max']),
      location: json['location'] as String?,
      jobType: json['job_type'] as String?,
      isApplied: json['isApplied'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,

      // Xử lý object company lồng nhau
      company: json['company'] != null && json['company'] is Map
          ? CompanyEntity.fromJson(json['company'] as Map<String, dynamic>)
          : null,

      skills: skillsList, // ⭐️ Gán skills
    );
  }

  // --- ⭐️ FACTORY MỚI (Để đọc JSON phẳng từ API danh sách) ---
  factory JobEntity.fromFlatJson(Map<String, dynamic> json) {
    // Helper để parse double một cách an toàn
    double? parseDoubleSafe(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // 1. Đọc các trường phẳng từ DTO
    final companyName = json['company_name'] as String?;
    final logoUrl = json['logo_url'] as String?;
    final int companyId = json['company_id'] as int? ?? 0;
    // 2. "Tái tạo" (re-hydrate) đối tượng CompanyEntity
    CompanyEntity? companyInstance;
    if (companyName != null) {
      companyInstance = CompanyEntity(
        // Giả sử CompanyEntity có constructor phù hợp
        // Đây là ví dụ, bạn cần chỉnh cho khớp với CompanyEntity
        companyId: companyId, // Không có ID từ JSON phẳng, dùng tạm 0
        name: companyName,
        logoUrl: logoUrl,
        // Các trường khác sẽ là null hoặc giá trị mặc định...
      );
    }

    // 3. Đọc skills
    final skillsList =
        (json['skills'] as List<dynamic>?)
            ?.map((e) => e.toString())
            ?.toList() ??
            <String>[];

    // 4. Trả về JobEntity
    return JobEntity(
      jobId: json['job_id'] as int? ?? 0,
      title: json['title'] as String? ?? 'N/A',
      description: json['description'] as String?,
      requirements: json['requirements'] as String?,
      location: json['location'] as String?,
      jobType: json['job_type'] as String?,
      salaryMin: parseDoubleSafe(json['salary_min']),
      salaryMax: parseDoubleSafe(json['salary_max']),

      // Gán đối tượng company vừa "tái tạo"
      company: companyInstance,

      // Gán skills
      skills: skillsList,

      // Cờ trạng thái
      isApplied: json['isApplied'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }
}