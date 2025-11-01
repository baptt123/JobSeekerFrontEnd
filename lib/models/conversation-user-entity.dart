// models/conversation_user.model.dart (TẠO FILE MỚI)

class ConversationUserEntity {
  final int id;
  final String fullName;
  final String email;
  final String? avatarUrl; // Có thể null

  ConversationUserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
  });

  factory ConversationUserEntity.fromJson(Map<String, dynamic> json) {
    return ConversationUserEntity(
      id: json['user_id'], // Khớp với key của NestJS
      fullName: json['full_name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
    );
  }
}