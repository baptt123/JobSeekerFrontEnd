// Enum để xác định loại thông báo cho UI
import 'package:firebase_messaging/firebase_messaging.dart';
enum NotificationType {
  jobApplied,
  accountVerified,
  profileUpdated,
  unknown,
}

class NotificationDto {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final NotificationType type;

  NotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.type,
  });

  // Factory constructor để parse từ JSON (ví dụ từ API hoặc FCM data)
  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    String title = json['title'] ?? 'Không có tiêu đề';

    // Tự động xác định type dựa trên title
    NotificationType type = NotificationType.unknown;
    if (title.toLowerCase().contains('job applied')) {
      type = NotificationType.jobApplied;
    } else if (title.toLowerCase().contains('account verified')) {
      type = NotificationType.accountVerified;
    } else if (title.toLowerCase().contains('profile updated')) {
      type = NotificationType.profileUpdated;
    }

    return NotificationDto(
      id: json['notification_id'] as int,
      title: title,
      message: json['message'] ?? '',
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      type: type,
    );
  }

  // Factory constructor để parse từ RemoteMessage (FCM)
  factory NotificationDto.fromRemoteMessage(RemoteMessage message) {
    // FCM có 2 phần: notification (hiển thị) và data (payload)
    // Backend của bạn nên gửi data payload
    final data = message.data;

    // Giả sử backend gửi data payload khớp với model
    return NotificationDto.fromJson({
      // Dùng các trường trong 'data'
      'notification_id': int.tryParse(data['notification_id'] ?? '0') ?? DateTime.now().millisecondsSinceEpoch,
      'title': data['title'] ?? message.notification?.title ?? 'Thông báo mới',
      'message': data['message'] ?? message.notification?.body ?? '',
      'is_read': false, // Mới nhận nên là false
      'created_at': DateTime.now().toIso8601String(), // Thời điểm nhận
      // Bạn nên gửi 'type' từ backend, ví dụ: data['type'] = 'jobApplied'
      // Ở đây tôi tự suy luận từ title
    });
  }
}