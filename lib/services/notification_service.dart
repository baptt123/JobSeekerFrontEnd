import '../dto/notification_dto.dart';

class NotificationService {
  // Giả lập việc gọi API để lấy danh sách thông báo
  // Trong tương lai, bạn sẽ thay thế bằng http.get(...)
  Future<List<NotificationDto>> getNotifications() async {
    // Giả lập độ trễ mạng
    await Future.delayed(const Duration(milliseconds: 500));

    // Dữ liệu giả lập khớp với giao diện
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    return [
      NotificationDto(
        id: 1,
        title: 'Job Applied',
        message: 'Waiting for the recruitments reply your application.',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 1)), // Today
        type: NotificationType.jobApplied,
      ),
      NotificationDto(
        id: 2,
        title: 'Account Verified',
        message: 'Your account will be verified',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)), // Today
        type: NotificationType.accountVerified,
      ),
      NotificationDto(
        id: 3,
        title: 'Profile Updated',
        message: 'Your profile details has been updated successfully.',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 3)), // Today
        type: NotificationType.profileUpdated,
      ),
      NotificationDto(
        id: 4,
        title: 'Job Applied',
        message: 'Waiting for the recruitments reply your application.',
        isRead: true,
        createdAt: yesterday.subtract(const Duration(hours: 5)), // Yesterday
        type: NotificationType.jobApplied,
      ),
      NotificationDto(
        id: 5,
        title: 'Profile Updated',
        message: 'Your profile details has been updated successfully.',
        isRead: true,
        createdAt: yesterday.subtract(const Duration(hours: 10)), // Yesterday
        type: NotificationType.profileUpdated,
      ),
    ];
  }
}