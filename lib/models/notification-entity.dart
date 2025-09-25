class NotificationEntity {
  final int notificationId;
  final int userId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationEntity({
    required this.notificationId,
    required this.userId,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) =>
      NotificationEntity(
        notificationId: json['notification_id'],
        userId: json['user_id'],
        message: json['message'],
        isRead: (json['is_read'] ?? 0) == 1,
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
    'notification_id': notificationId,
    'user_id': userId,
    'message': message,
    'is_read': isRead ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
  };
}
