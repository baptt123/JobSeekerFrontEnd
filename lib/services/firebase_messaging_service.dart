// lib/services/firebase_messaging_service.dart

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:job_seeker_frontend/services/local_notification_service.dart';
import 'package:job_seeker_frontend/services/user_service.dart';
import 'package:job_seeker_frontend/utils/global_keys.dart';
import 'package:job_seeker_frontend/views/login/user/job_detail_screen.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final UserService _userService = UserService();

  // 1. Chỉ khởi tạo các bộ lắng nghe sự kiện
  void initNotificationListeners(Function(RemoteMessage) onMessageCallback) {
    // Khi app đang mở (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        LocalNotificationService.showNotification(
          title: message.notification!.title ?? 'Thông báo',
          body: message.notification!.body ?? '',
        );
      }
      onMessageCallback(message);
    });

    // Khi click vào thông báo từ thanh trạng thái (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data);
    });

    // Khi click vào thông báo lúc app đã bị tắt hẳn (Terminated)
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        Future.delayed(const Duration(seconds: 2), () {
          _handleNotificationClick(message.data);
        });
      }
    });
  }

  // 2. 🔥 HÀM HỎI QUYỀN MẶC ĐỊNH (Sửa lại theo yêu cầu)
  // Xóa bỏ dialog custom, dùng dialog chuẩn của Firebase/OS
  Future<void> forceRequestPermission(BuildContext context) async {
    // Gọi hàm requestPermission của Firebase.
    // Hàm này tự động xử lý việc hiển thị Dialog hệ thống trên iOS và Android 13+.
    // Nếu user đã chọn trước đó, nó sẽ trả về trạng thái ngay mà không hiện lại popup.
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      providesAppNotificationSettings: true,
    );

    print('User permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Người dùng ĐỒNG Ý nhận thông báo.");
      // Chỉ khi đồng ý mới lấy token và gửi lên server
      await _setupNotificationAfterAgreement();
    } else {
      print("❌ Người dùng TỪ CHỐI hoặc chưa cấp quyền.");
      // Nếu từ chối, xóa token trên server để không gửi thông báo
      await _userService.updateFcmToken(null);
      await _firebaseMessaging.unsubscribeFromTopic('job_alerts');
    }
  }

  // Luồng cấu hình sau khi có sự đồng ý
  Future<void> _setupNotificationAfterAgreement() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _userService.updateFcmToken(token);
      print("🚀 Đồng bộ Token thành công: $token");
    }
    await _firebaseMessaging.subscribeToTopic('job_alerts');
  }

  Future<void> subscribeToUserTopic(int userId) async {
    await _firebaseMessaging.subscribeToTopic('user_$userId');
  }

  Future<void> unsubscribeFromUserTopic(int userId) async {
    await _firebaseMessaging.unsubscribeFromTopic('user_$userId');
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    final navigator = ManagingGlobalKey.navigatorKey.currentState;
    if (navigator == null) return;

    final String type = data['type']?.toString() ?? '';
    if (type == 'CHAT_MSG' || data['click_action'] == 'CHAT_DETAIL') {
      final otherUserIdStr = data['senderId'] ?? data['other_user_id'];
      if (otherUserIdStr != null) {
        // Logic điều hướng chat (giữ nguyên)
      }
    } else if (type == 'NEW_JOB_POST' || type == 'APPLICATION_UPDATE') {
      if (data['job_title'] != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => JobDetailScreen(jobTitle: data['job_title']),
          ),
        );
      }
    }
  }
}
