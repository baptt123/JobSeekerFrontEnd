// 📄 [TẠO MỚI] lib/dto/create_cv_dto.dart (để khớp với backend)
// (Bạn cần tạo file này để Flutter hiểu cấu trúc dữ liệu)
class ExperienceDto {
  final String jobTitle;
  final String company;
  final String duration;
  final String description;

  ExperienceDto({
    required this.jobTitle,
    required this.company,
    required this.duration,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'jobTitle': jobTitle,
    'company': company,
    'duration': duration,
    'description': description,
  };
}