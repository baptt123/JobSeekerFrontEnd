// lib/dto/filter_job_dto.dart

class FilterJobDto {
  String? location;
  // Đã bỏ salary_min, salary_max
  String? job_type; // Full-time, Part-time, Intern, Remote
  int? size;

  FilterJobDto({
    this.location,
    this.job_type,
    this.size = 20,
  });

  // Chuyển DTO thành Map để dùng trong query parameters của Dio
  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {};

    if (location != null && location!.isNotEmpty) {
      params['location'] = location;
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
          (job_type == null || job_type!.isEmpty);
}