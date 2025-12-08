import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message-entity.dart';
import '../utils/constant_api.dart';

class MessageService {
  IO.Socket? _socket;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Callbacks để cập nhật UI
  final Function(MessageEntity) onMessageReceived;
  final Function(MessageEntity) onMessageSentConfirmed;
  final Function(List<MessageEntity>) onConversationLoaded;
  final Function(int) onUserConnected;

  MessageService({
    required this.onMessageReceived,
    required this.onMessageSentConfirmed,
    required this.onConversationLoaded,
    required this.onUserConnected,
  });

  Future<void> connect() async {
    final accessToken = await _storage.read(key: 'accessToken');
    if (accessToken == null) {
      print("❌ ChatService: No access token found.");
      return;
    }

    // Cấu hình Socket.IO Client
    _socket = IO.io(
        ConstantAPI.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket']) // Bắt buộc dùng websocket để ổn định
            .disableAutoConnect()
        // 🔥 QUAN TRỌNG: Gửi token vào Header để NestJS Gateway xác thực
            .setExtraHeaders({
          'Authorization': 'Bearer $accessToken',
        })
            .build());

    // --- LẮNG NGHE SỰ KIỆN ---

    _socket?.onConnect((_) {
      print('✅ Socket connected: ${_socket?.id}');
    });

    _socket?.on('connected', (data) {
      print('✅ Server acknowledged connection. User ID: ${data['userId']}');
      onUserConnected(data['userId'] as int);
    });

    _socket?.on('receiveMessage', (data) {
      final message = MessageEntity.fromJson(data);
      onMessageReceived(message);
    });

    _socket?.on('messageSent', (data) {
      // Server xác nhận tin nhắn đã được lưu DB
      final message = MessageEntity.fromJson(data);
      onMessageSentConfirmed(message);
    });

    _socket?.on('conversationLoaded', (data) {
      final messages = (data as List)
          .map((msgJson) => MessageEntity.fromJson(msgJson))
          .toList();
      onConversationLoaded(messages);
    });

    _socket?.onDisconnect((_) => print('❌ Socket disconnected'));
    _socket?.onError((data) => print('⚠️ Socket error: $data'));

    // Bắt đầu kết nối
    _socket?.connect();
  }

  // Gửi tin nhắn
  void sendMessage(Map<String, dynamic> messageData) {
    _socket?.emit('sendMessage', messageData);
  }

  // Tải lịch sử chat
  void loadConversation(int otherUserId) {
    _socket?.emit('loadConversation', {
      'otherUserId': otherUserId,
    });
  }

  // Đánh dấu đã đọc
  void markAsRead(int senderId) {
    _socket?.emit('markAsRead', {
      'senderId': senderId,
    });
  }

  void disconnect() {
    _socket?.dispose();
  }
}