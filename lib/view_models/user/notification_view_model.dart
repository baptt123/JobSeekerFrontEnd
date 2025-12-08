// lib/view_models/user/notification_view_model.dart

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:job_seeker_frontend/models/notification-entity.dart';
import 'package:job_seeker_frontend/services/firebase_messaging_service.dart';
import 'package:job_seeker_frontend/services/notification_service.dart';

enum NotificationState { loading, loaded, error, unauthorized }

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final FirebaseMessagingService _fcmService = FirebaseMessagingService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  NotificationState _state = NotificationState.loading;
  List<NotificationEntity> _notifications = [];
  int _unreadCount = 0;

  NotificationState get state => _state;
  List<NotificationEntity> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  NotificationViewModel() {
    initialize();
  }

  Future<void> initialize() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) {
      _state = NotificationState.unauthorized;
      notifyListeners();
      return;
    }

    // Lấy Device Token để nhận thông báo đẩy
    await _fcmService.getDeviceToken();

    // Tải dữ liệu lần đầu
    await fetchNotifications();

    // Lắng nghe thông báo mới (Real-time)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Khi có thông báo mới -> Reload list để cập nhật UI & Badge
      fetchNotifications();
    });
  }

  Future<void> fetchNotifications() async {
    if (_notifications.isEmpty) {
      _state = NotificationState.loading;
      notifyListeners();
    }

    try {
      // Gọi service không cần userId
      final result = await _notificationService.getNotifications();
      _notifications = result;

      // Tính toán số lượng chưa đọc
      _unreadCount = _notifications.where((n) => !n.isRead).length;

      _state = NotificationState.loaded;
    } catch (e) {
      if (e.toString().contains("401")) {
        _state = NotificationState.unauthorized;
      } else {
        _state = NotificationState.error;
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    // 1. Cập nhật UI ngay lập tức (Optimistic Update)
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      // Vì NotificationEntity là final, ta cần cẩn thận hoặc backend trả về list mới
      // Ở đây ta tạm thời gán cờ local nếu Model cho phép, hoặc fetch lại
      // Cách tốt nhất là fetch lại hoặc update local count

      // Giả sử logic update local:
      // (Bạn cần bỏ 'final' ở field isRead trong Model hoặc tạo copyWith)
      // _notifications[index].isRead = true;

      _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
      notifyListeners();

      // 2. Gọi API ngầm
      await _notificationService.markAsRead(notificationId);

      // 3. Reload để đồng bộ chính xác
      await fetchNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    _unreadCount = 0;
    notifyListeners();
    await _notificationService.markAllAsRead();
    await fetchNotifications();
  }
}