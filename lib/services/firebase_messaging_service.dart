import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import '../dto/notification_dto.dart';

class FirebaseMessagingService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // StreamController để ViewModel có thể lắng nghe thông báo mới
  final StreamController<NotificationDto> _newMessageController =
  StreamController.broadcast();
  Stream<NotificationDto> get onNewMessage => _newMessageController.stream;

  Future<void> initialize() async {
    // 1. Yêu cầu quyền
    await _firebaseMessaging.requestPermission();

    // 2. Lấy FCM Token
    final fcmToken = await _firebaseMessaging.getToken();
    print('=================================');
    print('FCM Token: $fcmToken');
    print('=================================');
    // TRONG THỰC TẾ: Bạn cần gửi token này về backend để lưu vào UserEntity

    // 3. Lắng nghe thông báo khi app đang mở (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }

      // Chuyển RemoteMessage thành DTO và đẩy vào stream
      _newMessageController.add(NotificationDto.fromRemoteMessage(message));
    });

    // 4. Lắng nghe khi người dùng click vào thông báo (khi app ở Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // TODO: Điều hướng người dùng đến màn hình chi tiết
      // Ví dụ: navigatorKey.currentState.pushNamed('/notification_detail', arguments: message.data['id']);

      // Ở đây chúng ta cũng có thể thêm nó vào danh sách
      _newMessageController.add(NotificationDto.fromRemoteMessage(message));
    });
  }

  void dispose() {
    _newMessageController.close();
  }
}