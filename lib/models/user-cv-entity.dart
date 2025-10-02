class UserCVEntity {
  final int cvId;
  final int userId;
  final String? title;
  final String? fileUrl;
  final String? content;
  final bool isDefault;
  final DateTime createdAt;

  UserCVEntity({
    required this.cvId,
    required this.userId,
    this.title,
    this.fileUrl,
    this.content,
    required this.isDefault,
    required this.createdAt,
  });

  factory UserCVEntity.fromJson(Map<String, dynamic> json) => UserCVEntity(
    cvId: json['cv_id'],
    userId: json['user_id'],
    title: json['title'],
    fileUrl: json['file_url'],
    content: json['content'],
    isDefault: json['is_default'],
    createdAt: DateTime.parse(json['created_at']),
  );
}
