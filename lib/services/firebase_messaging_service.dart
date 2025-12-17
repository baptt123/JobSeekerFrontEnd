// lib/services/firebase_messaging_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/services/local_notification_service.dart';
import 'package:job_seeker_frontend/utils/global_keys.dart';
import 'package:job_seeker_frontend/views/login/user/job_detail_screen.dart';
import 'package:job_seeker_frontend/views/login/user/message_screen.dart'; // Import MessageScreen

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize(Function(RemoteMessage) onMessageCallback) async {
    // 1. Xin quyền
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Đăng ký Topic chung (Job Alerts)
    await _firebaseMessaging.subscribeToTopic('job_alerts');

    // 3. Lắng nghe tin nhắn khi App đang mở (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 Foreground Message received: ${message.notification?.title}');

      // Nếu có Notification -> Hiện Banner
      if (message.notification != null) {
        LocalNotificationService.showNotification(
          title: message.notification!.title ?? 'Thông báo',
          body: message.notification!.body ?? 'Bạn có tin nhắn mới.',
          // payload: message.data.toString(), // (Tuỳ chọn: Nếu LocalNotification hỗ trợ payload)
        );
      }
      onMessageCallback(message);
    });

    // 4. Click thông báo khi App chạy ngầm
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data);
    });

    // 5. Click thông báo khi App tắt hẳn
    final RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(seconds: 2), () {
        _handleNotificationClick(initialMessage.data);
      });
    }
  }

  // --- [MỚI] Hàm đăng ký nhận tin riêng cho User ---
  // Gọi hàm này sau khi Login thành công
  Future<void> subscribeToUserTopic(int userId) async {
    String topic = 'user_$userId'; // Ví dụ: user_10
    await _firebaseMessaging.subscribeToTopic(topic);
    print("✅ Đã đăng ký nhận tin chat cho topic: $topic");
  }

  // --- [MỚI] Hàm hủy đăng ký (Gọi khi Logout) ---
  Future<void> unsubscribeFromUserTopic(int userId) async {
    String topic = 'user_$userId';
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print("👋 Đã hủy đăng ký topic: $topic");
  }

  // --- XỬ LÝ ĐIỀU HƯỚNG ---
  void _handleNotificationClick(Map<String, dynamic> data) {
    print("🚀 Payload Data: $data");

    final navigator = ManagingGlobalKey.navigatorKey.currentState;
    if (navigator == null) return;

    // CASE 1: Chat Message
    // Kiểm tra các key thường dùng: click_action, type, hoặc senderId
    if (data['click_action'] == 'CHAT_DETAIL' || data['type'] == 'CHAT_MSG') {

      // Parse dữ liệu an toàn (tránh lỗi String/Int)
      final otherUserIdStr = data['senderId'] ?? data['other_user_id'];

      if (otherUserIdStr != null) {
        final int otherUserId = int.parse(otherUserIdStr.toString());
        final String otherUserName = data['senderName'] ?? data['other_user_name'] ?? 'Nhà tuyển dụng';
        final String otherUserAvatar = data['senderAvatar'] ?? data['other_user_avatar'] ?? '';

        print("💬 Mở màn hình chat với ID: $otherUserId");

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
    // CASE 2: Job Detail (Như cũ)
    else if (data['type'] == 'NEW_JOB_POST' || data['click_action'] == 'JOB_DETAIL') {
      if (data['job_title'] != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => JobDetailScreen(jobTitle: data['job_title']),
          ),
        );
      }
    }
  }

  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }
}