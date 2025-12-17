class CommentEntity {
  final int id;
  final String content;
  final DateTime createdAt;
  // Frontend tự quy định tên hiển thị
  String get displayName => "Người tìm việc ẩn danh";

  CommentEntity({required this.id, required this.content, required this.createdAt});

  factory CommentEntity.fromJson(Map<String, dynamic> json) {
    return CommentEntity(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}