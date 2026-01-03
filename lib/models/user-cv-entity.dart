import 'dart:convert'; // Import để decode JSON

class UserCvEntity {
  int? cvId;
  int? userId;
  String? title;
  String? cvUrl;
  bool? isDefault;
  bool? isDeleted; // Thêm trường này
  String? content; // Thêm trường này (lưu chuỗi JSON từ AI)
  DateTime? createdAt;

  // Getter helper để lấy list skills từ chuỗi content JSON
  List<String> get extractedSkills {
    if (content == null || content!.isEmpty) return [];
    try {
      // Content lưu dạng: '{"skills": ["A", "B"], "keywords": [...] }'
      final Map<String, dynamic> data = jsonDecode(content!);
      if (data['skills'] != null) {
        return List<String>.from(data['skills']);
      }
    } catch (e) {
      return [];
    }
    return [];
  }

  UserCvEntity({
    this.cvId,
    this.userId,
    this.title,
    this.cvUrl,
    this.isDefault,
    this.isDeleted,
    this.content,
    this.createdAt,
  });

  factory UserCvEntity.fromJson(Map<String, dynamic> json) {
    return UserCvEntity(
      cvId: json['cv_id'] ?? json['id'],
      userId: json['user_id'],
      title: json['title'] ?? 'CV Không tên',
      cvUrl: json['file_url'] ?? json['cvUrl'],
      isDefault: json['is_default'] ?? json['isDefault'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      content: json['content'], // Map trường content
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}