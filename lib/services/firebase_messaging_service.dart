// lib/services/firebase_messaging_service.dart

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:job_seeker_frontend/services/local_notification_service.dart';
import 'package:job_seeker_frontend/services/user_service.dart';
import 'package:job_seeker_frontend/utils/global_keys.dart';
// [THÊM MỚI] Import trang thông báo
import 'package:job_seeker_frontend/views/login/user/notification_screen.dart';

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

  // 2. 🔥 HÀM HỎI QUYỀN MẶC ĐỊNH
  Future<void> forceRequestPermission(BuildContext context) async {
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
      await _setupNotificationAfterAgreement();
    } else {
      print("❌ Người dùng TỪ CHỐI hoặc chưa cấp quyền.");
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

  // [CHỈNH SỬA] Hàm xử lý click: Luôn trỏ về NotificationScreen
  void _handleNotificationClick(Map<String, dynamic> data) {
    final navigator = ManagingGlobalKey.navigatorKey.currentState;
    if (navigator == null) return;

    // Logic cũ: Kiểm tra type để điều hướng (đã comment lại hoặc bỏ qua)
    // final String type = data['type']?.toString() ?? '';

    // Logic mới: Bắt buộc vào trang thông báo bất kể chủ đề gì
    print("🔔 Notification Clicked: Navigating to NotificationScreen");
    navigator.push(
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
      ),
    );
  }
}