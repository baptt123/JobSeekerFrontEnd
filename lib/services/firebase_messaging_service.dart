// lib/services/firebase_messaging_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/services/local_notification_service.dart';
import 'package:job_seeker_frontend/utils/global_keys.dart'; // Import Key
import 'package:job_seeker_frontend/views/login/user/job_detail_screen.dart';
import 'package:job_seeker_frontend/views/login/user/message_screen.dart'; // [MỚI] Import MessageScreen

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize(Function(RemoteMessage) onMessageCallback) async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 1. App đang mở (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      // Hiển thị thông báo Local
      if (message.notification != null) {
        LocalNotificationService.showNotification(
          title: message.notification!.title ?? 'Thông báo',
          body: message.notification!.body ?? 'Bạn có tin nhắn mới.',
        );
      }
      onMessageCallback(message);
    });

    // 2. App chạy ngầm (Background) -> Click thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _handleNotificationClick(message.data);
    });

    // 3. App tắt hẳn (Terminated) -> Click thông báo
    final RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(seconds: 2), () {
        _handleNotificationClick(initialMessage.data);
      });
    }
  }

  // --- HÀM ĐIỀU HƯỚNG TẬP TRUNG ---
  void _handleNotificationClick(Map<String, dynamic> data) {
    print("Handling notification click payload: $data");

    final navigator = ManagingGlobalKey.navigatorKey.currentState;
    if (navigator == null) return;

    // CASE 1: Xem chi tiết Job
    if (data['click_action'] == 'JOB_DETAIL' && data['job_title'] != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (context) => JobDetailScreen(jobTitle: data['job_title']),
        ),
      );
    }
    // CASE 2: Xem chi tiết Application
    else if (data['click_action'] == 'APPLICATION_DETAIL' && data['job_id'] != null) {
      // Logic tương tự JOB_DETAIL hoặc mở màn hình quản lý đơn
      // Tạm thời mở Job Detail nếu có title
      if (data['job_title'] != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => JobDetailScreen(jobTitle: data['job_title']),
          ),
        );
      }
    }
    // CASE 3: [MỚI] Chat Message -> Mở màn hình chat
    else if (data['click_action'] == 'CHAT_DETAIL') {
      final otherUserIdStr = data['other_user_id'];

      if (otherUserIdStr != null) {
        // Parse ID về int (Backend gửi về có thể là string hoặc number)
        final int otherUserId = int.parse(otherUserIdStr.toString());
        final String otherUserName = data['other_user_name'] ?? 'Người dùng';
        final String otherUserAvatar = data['other_user_avatar'] ?? '';

        navigator.push(
          MaterialPageRoute(
            builder: (context) => MessageScreen(
              otherUserId: otherUserId,
              otherUserName: otherUserName,
              otherUserAvatar: otherUserAvatar,
            ),
          ),
        );
      }
    }
  }

  Future<String?> getDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('Firebase FCM Token: $token');
    return token;
  }
}