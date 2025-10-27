// lib/models/filter_job_dto.dart

class FilterJobDto {
  String? location;
  num? salary_min;
  num? salary_max;
  String? job_type; // Full-time, Part-time, Intern, Remote
  int? size;

  FilterJobDto({
    this.location,
    this.salary_min,
    this.salary_max,
    this.job_type,
    this.size = 20, // Giống backend
  });

  // Chuyển DTO thành Map để dùng trong query parameters của Dio
  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {};

    // Chỉ thêm vào map nếu giá trị không null hoặc rỗng
    if (location != null && location!.isNotEmpty) {
      params['location'] = location;
    }
    if (salary_min != null) {
      params['salary_min'] = salary_min.toString();
    }
    if (salary_max != null) {
      params['salary_max'] = salary_max.toString();
    }
    if (job_type != null && job_type!.isNotEmpty) {
      params['job_type'] = job_type;
    }
    if (size != null) {
      params['size'] = size.toString();
    }

    return params;
  }

  // Kiểm tra xem có filter nào đang được áp dụng không
  bool get isClear =>
      (location == null || location!.isEmpty) &&
          salary_min == null &&
          salary_max == null &&
          (job_type == null || job_type!.isEmpty);
}