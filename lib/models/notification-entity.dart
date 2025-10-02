class NotificationEntity {
  final int notificationId;
  final int userId;
  final String? title;
  final String? message;
  final bool isRead;
  final DateTime createdAt;

  NotificationEntity({
    required this.notificationId,
    required this.userId,
    this.title,
    this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) =>
      NotificationEntity(
        notificationId: json['notification_id'],
        userId: json['user_id'],
        title: json['title'],
        message: json['message'],
        isRead: json['is_read'],
        createdAt: DateTime.parse(json['created_at']),
      );
}
