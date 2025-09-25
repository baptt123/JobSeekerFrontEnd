class UserCvEntity {
  final int cvId;
  final int userId;
  final String? title;
  final String? fileUrl;
  final String? content;
  final bool isDefault;
  final DateTime createdAt;

  UserCvEntity({
    required this.cvId,
    required this.userId,
    this.title,
    this.fileUrl,
    this.content,
    this.isDefault = false,
    required this.createdAt,
  });

  factory UserCvEntity.fromJson(Map<String, dynamic> json) => UserCvEntity(
    cvId: json['cv_id'],
    userId: json['user_id'],
    title: json['title'],
    fileUrl: json['file_url'],
    content: json['content'],
    isDefault: (json['is_default'] ?? 0) == 1,
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'cv_id': cvId,
    'user_id': userId,
    'title': title,
    'file_url': fileUrl,
    'content': content,
    'is_default': isDefault ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
  };
}
