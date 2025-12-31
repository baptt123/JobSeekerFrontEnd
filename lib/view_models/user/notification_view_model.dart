// lib/view_models/user/notification_view_model.dart

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:job_seeker_frontend/models/notification-entity.dart';
import 'package:job_seeker_frontend/services/notification_service.dart';

enum NotificationState { loading, loaded, error, unauthorized }

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
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

    // Tải dữ liệu từ Database (luôn tải dù có quyền Push hay không)
    await fetchNotifications();

    // [CẬP NHẬT] Lắng nghe Firebase để làm mới danh sách khi có tin nhắn mới
    // Việc này đảm bảo khi App đang mở (Foreground), danh sách thông báo sẽ tự cập nhật ngay.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Nhận thông báo mới khi đang ở màn hình danh sách, reload...");
      fetchNotifications();
    });
  }

  Future<void> fetchNotifications() async {
    // Chỉ hiện loading ở lần đầu tiên
    if (_notifications.isEmpty) {
      _state = NotificationState.loading;
      notifyListeners();
    }

    try {
      final result = await _notificationService.getNotifications();
      _notifications = result;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _state = NotificationState.loaded;
    } catch (e) {
      _state = e.toString().contains("401") ? NotificationState.unauthorized : NotificationState.error;
    } finally {
      notifyListeners();
    }
  }

  // Đánh dấu đã đọc
  Future<void> markAsRead(int notificationId) async {
    // Cập nhật local trước để UI mượt mà (Optimistic Update)
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
      notifyListeners();

      // Gọi API thực tế
      bool success = await _notificationService.markAsRead(notificationId);
      if (success) {
        // Tải lại để cập nhật trạng thái chính xác từ Backend
        await fetchNotifications();
      }
    }
  }

  Future<void> markAllAsRead() async {
    _unreadCount = 0;
    notifyListeners();
    await _notificationService.markAllAsRead();
    await fetchNotifications();
  }
}