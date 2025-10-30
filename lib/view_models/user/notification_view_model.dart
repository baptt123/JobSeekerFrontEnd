import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../dto/notification_dto.dart';
import '../../services/firebase_messaging_service.dart';
import '../../services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  // Services
  final NotificationService _notificationService = NotificationService();
  final FirebaseMessagingService _firebaseMessagingService = FirebaseMessagingService();

  // State
  List<NotificationDto> _notifications = [];
  Map<String, List<NotificationDto>> _groupedNotifications = {};
  bool _isLoading = false;

  // Getters cho View
  Map<String, List<NotificationDto>> get groupedNotifications => _groupedNotifications;
  bool get isLoading => _isLoading;

  // Constructor
  NotificationViewModel() {
    _initialize();
  }

  void _initialize() async {
    // 1. Khởi tạo FCM
    await _firebaseMessagingService.initialize();

    // 2. Lắng nghe thông báo mới từ FCM Service
    _firebaseMessagingService.onNewMessage.listen(_onNewNotification);

    // 3. Tải danh sách thông báo ban đầu
    fetchNotifications();
  }

  // Khi có thông báo mới từ FCM
  void _onNewNotification(NotificationDto notification) {
    // Thêm vào đầu danh sách
    _notifications.insert(0, notification);
    _groupNotifications(); // Sắp xếp lại
    notifyListeners();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications();
      _groupNotifications();
    } catch (e) {
      // Xử lý lỗi
      print(e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  // Logic để nhóm thông báo theo "Today", "Yesterday"
  void _groupNotifications() {
    _groupedNotifications = {}; // Xóa nhóm cũ

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var notif in _notifications) {
      final notifDate = DateTime(notif.createdAt.year, notif.createdAt.month, notif.createdAt.day);
      String groupKey;

      if (notifDate == today) {
        groupKey = 'Today';
      } else if (notifDate == yesterday) {
        groupKey = 'Yesterday';
      } else {
        // Bạn có thể format ngày khác ở đây, ví dụ: 'October 26'
        groupKey = DateFormat('MMMM d').format(notif.createdAt);
      }

      if (_groupedNotifications[groupKey] == null) {
        _groupedNotifications[groupKey] = [];
      }
      _groupedNotifications[groupKey]!.add(notif);
    }
  }

  @override
  void dispose() {
    _firebaseMessagingService.dispose();
    super.dispose();
  }
}