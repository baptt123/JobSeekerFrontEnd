class UserCvEntity {
  int? cvId;
  int? userId;
  String? title;
  String? cvUrl;       // Map từ file_url
  bool? isDefault;     // Map từ is_default
  DateTime? createdAt;

  UserCvEntity({
    this.cvId,
    this.userId,
    this.title,
    this.cvUrl,
    this.isDefault,
    this.createdAt,
  });

  factory UserCvEntity.fromJson(Map<String, dynamic> json) {
    return UserCvEntity(
      cvId: json['cv_id'] ?? json['id'], // Handle cả 2 trường hợp tên field
      userId: json['user_id'],
      title: json['title'] ?? 'CV Không tên',
      cvUrl: json['file_url'] ?? json['cvUrl'],
      isDefault: json['is_default'] ?? json['isDefault'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}