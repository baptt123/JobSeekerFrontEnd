// lib/view_models/user/notification_view_model.dart
// (Cập nhật file này)

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/models/notification-entity.dart';
import 'package:job_seeker_frontend/services/firebase_messaging_service.dart';
import 'package:job_seeker_frontend/services/notification_service.dart';

// Enum để quản lý các trạng thái
enum NotificationState { Initial, Loading, Loaded, Error }

class NotificationViewModel extends ChangeNotifier {
  // Dependencies
  final NotificationService _notificationService = NotificationService();
  final FirebaseMessagingService _fcmService = FirebaseMessagingService();

  // State
  NotificationState _state = NotificationState.Initial;
  List<NotificationEntity> _notifications = [];
  String _errorMessage = '';
  String? _deviceToken;

  // Getters
  NotificationState get state => _state;
  List<NotificationEntity> get notifications => _notifications;
  String get errorMessage => _errorMessage;
  String? get deviceToken => _deviceToken;

  // Giả sử bạn lấy user ID từ một service/provider khác
  // Tạm thời hardcode
  final int _currentUserId = 1;

  NotificationViewModel() {
    initialize();
  }

  // Khởi tạo
  Future<void> initialize() async {
    await _getDeviceToken();
    await fetchNotifications();

    // Lắng nghe các thông báo foreground
    _fcmService.initialize((message) {
      // Khi nhận được thông báo mới (foreground),
      // tự động refresh lại danh sách
      print("Foreground message received, refreshing list...");
      fetchNotifications();
    });
  }

  // Lấy danh sách thông báo từ CSDL
  Future<void> fetchNotifications() async {
    _setState(NotificationState.Loading);
    try {
      _notifications = await _notificationService.getNotificationsByUserId(_currentUserId);
      _setState(NotificationState.Loaded);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(NotificationState.Error);
    }
  }

  // Lấy FCM token
  Future<void> _getDeviceToken() async {
    _deviceToken = await _fcmService.getDeviceToken();
    notifyListeners();
  }

  // Gửi thông báo TEST
  Future<bool> sendTestNotification(String title, String body) async {
    if (_deviceToken == null) {
      _errorMessage = "Không thể lấy được device token.";
      _setState(NotificationState.Error);
      return false;
    }

    _setState(NotificationState.Loading);
    try {
      bool success = await _notificationService.sendTestNotification(
        token: _deviceToken!,
        title: title,
        body: body,
        userId: _currentUserId, // Gửi userId để backend lưu vào CSDL
      );

      if (success) {
        // Nếu gửi thành công, đợi 1 giây rồi refresh lại danh sách
        // để thấy thông báo mới vừa được lưu vào CSDL
        await Future.delayed(Duration(seconds: 1));
        await fetchNotifications(); // Tải lại danh sách
      } else {
        _errorMessage = "Gửi thông báo test thất bại.";
        _setState(NotificationState.Error);
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(NotificationState.Error);
      return false;
    }
  }

  // Helper quản lý state
  void _setState(NotificationState newState) {
    _state = newState;
    notifyListeners();
  }
}