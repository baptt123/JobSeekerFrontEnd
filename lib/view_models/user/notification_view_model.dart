// lib/view_models/user/notification_view_model.dart

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // [IMPORT] FCM
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
  String _errorMessage = '';
  int _unreadCount = 0; // [NEW] Biến đếm chưa đọc

  NotificationState get state => _state;
  List<NotificationEntity> get notifications => _notifications;
  String get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  // Constructor khởi tạo
  NotificationViewModel() {
    initialize();
  }

  // Hàm khởi tạo chính
  Future<void> initialize() async {
    // 1. Kiểm tra đăng nhập
    final token = await _storage.read(key: 'accessToken');
    if (token == null) {
      _state = NotificationState.unauthorized;
      notifyListeners();
      return;
    }

    // 2. Lấy Device Token (để server có thể gửi noti)
    await _fcmService.getDeviceToken();

    // 3. Tải danh sách thông báo ban đầu
    await fetchNotifications();

    // 4. [REAL-TIME] Lắng nghe thông báo mới khi App đang mở
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Có thông báo mới: ${message.notification?.title}");

      // Khi có thông báo mới -> Refresh lại danh sách API để đồng bộ
      // (Hoặc có thể append thủ công vào list nếu muốn tối ưu API call)
      fetchNotifications();
    });
  }

  Future<void> fetchNotifications() async {
    // Chỉ set loading lần đầu tiên, các lần refresh ngầm không hiện loading
    if (_notifications.isEmpty) {
      _state = NotificationState.loading;
      notifyListeners();
    }

    try {
      // Giả sử service getNotificationsByUserId đã handle việc lấy userID từ token hoặc truyền vào
      // Ở đây ta gọi API lấy list
      // Lưu ý: Cần update Service để trả về List<NotificationEntity>
      // Hoặc nếu Backend trả về {data: [], unreadCount: 5} thì parse tương ứng

      // Tạm thời dùng logic client-side count nếu API chỉ trả list
      // userId lấy từ token trong Service
      // Ở đây ta truyền tạm 0, Service sẽ tự dùng DioClient có token
      final result = await _notificationService.getNotificationsByUserId(0);

      _notifications = result;
      // Tính số lượng chưa đọc (client-side)
      _unreadCount = _notifications.where((n) => n.isRead == false).length;

      _state = NotificationState.loaded;
    } catch (e) {
      if (e.toString().contains("401")) {
        _state = NotificationState.unauthorized;
      } else {
        _errorMessage = e.toString();
        _state = NotificationState.error;
      }
    } finally {
      notifyListeners();
    }
  }

  // Hàm đánh dấu đã đọc (Optional - Cần API backend hỗ trợ)
  void markAsRead(int notificationId) {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1) {
      // _notifications[index].isRead = true; // Cần setter hoặc copyWith
      _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
      notifyListeners();
      // Gọi API mark read ở đây...
    }
  }
}