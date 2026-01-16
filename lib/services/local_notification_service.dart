// lib/services/local_notification_service.dart

import 'package:flutter/material.dart'; // [THÊM MỚI] Cần thiết cho MaterialPageRoute
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:job_seeker_frontend/utils/global_keys.dart'; // [THÊM MỚI] Để dùng navigatorKey
import 'package:job_seeker_frontend/views/login/user/notification_screen.dart'; // [THÊM MỚI] Import trang thông báo

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static int _notificationId = 0;

  /// Khởi tạo plugin
  static Future<void> initialize() async {
    // Android
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  /// Hiển thị notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String payload = '',
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'job_seeker_channel_id',
      'Job Seeker Notifications',
      channelDescription: 'Kênh thông báo của Job Seeker App',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    _notificationId++;

    await _notificationsPlugin.show(
      _notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Xử lý khi nhấn thông báo (Foreground)
  // [CHỈNH SỬA] Thêm logic điều hướng vào đây
  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    print('Nhấn vào local notification: ${response.payload}');

    // Sử dụng Global Key để điều hướng không cần context
    final navigator = ManagingGlobalKey.navigatorKey.currentState;

    if (navigator != null) {
      // Bắt buộc vào trang thông báo
      navigator.push(
        MaterialPageRoute(
          builder: (context) => const NotificationScreen(),
        ),
      );
    }
  }
}