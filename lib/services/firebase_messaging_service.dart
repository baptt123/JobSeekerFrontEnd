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

  // 1. Chỉ khởi tạo các bộ lắng nghe sự kiện (Không chứa logic hỏi quyền)
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

  // 2. 🔥 HÀM ÉP BUỘC HỎI QUYỀN TRÊN MỌI PHIÊN BẢN
  Future<void> forceRequestPermission(BuildContext context) async {
    bool userAgreed = false;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+: Gọi hộp thoại hệ thống trực tiếp
        PermissionStatus status = await Permission.notification.request();
        userAgreed = status.isGranted;
      } else {
        // Android < 13: Tự tạo hộp thoại hỏi vì hệ thống không có dialog này
        userAgreed = await _showCustomRationaleDialog(context) ?? false;
      }
    } else if (Platform.isIOS) {
      // iOS: Sử dụng hộp thoại hệ thống của Firebase
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true, badge: true, sound: true,
      );
      userAgreed = settings.authorizationStatus == AuthorizationStatus.authorized;
    }

    if (userAgreed) {
      print("✅ Người dùng đồng ý nhận thông báo.");
      await _setupNotificationAfterAgreement();
    } else {
      print("❌ Người dùng từ chối nhận thông báo.");
      // Xóa token trên server để đảm bảo không gửi Push
      await _userService.updateFcmToken(null);
      await _firebaseMessaging.unsubscribeFromTopic('job_alerts');
    }
  }

  // Hộp thoại giải thích tùy chỉnh cho Android cũ
  Future<bool?> _showCustomRationaleDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Bật thông báo ứng dụng"),
        content: const Text(
            "Bạn có muốn nhận thông báo về việc làm mới, tin nhắn từ nhà tuyển dụng và cập nhật trạng thái hồ sơ không?"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("TỪ CHỐI", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ĐỒNG Ý", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
      }
    } else if (type == 'NEW_JOB_POST' || type == 'APPLICATION_UPDATE') {
      if (data['job_title'] != null) {
        navigator.push(MaterialPageRoute(
          builder: (context) => JobDetailScreen(jobTitle: data['job_title']),
        ));
      }
    }
  }
}