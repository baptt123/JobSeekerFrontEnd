// lib/services/firebase_messaging_service.dart
// (Đã điều chỉnh đầy đủ)

import 'package:firebase_messaging/firebase_messaging.dart';
// 1. Import service local notifications
import 'package:job_seeker_frontend/services/local_notification_service.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize(Function(RemoteMessage) onMessageCallback) async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Xử lý khi ứng dụng đang mở (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      // 2. PHẦN ĐIỀU CHỈNH QUAN TRỌNG:
      // Kiểm tra xem tin nhắn có phần notification không
      if (message.notification != null) {
        // Nếu có, dùng LocalNotificationService để *hiển thị* nó
        LocalNotificationService.showNotification(
          title: message.notification!.title ?? 'Thông báo',
          body: message.notification!.body ?? 'Bạn có tin nhắn mới.',
          // (Tùy chọn) Bạn có thể truyền data vào payload
          // payload: jsonEncode(message.data),
        );
      }

      // 3. Gọi callback để ViewModel biết và refresh (vẫn giữ)
      onMessageCallback(message);
    });

    // Xử lý khi nhấn vào thông báo (khi app bị tắt hoặc ở background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // TODO: Điều hướng dựa trên message.data
    });
  }

  Future<String?> getDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('Firebase FCM Token: $token');
    return token;
  }
}