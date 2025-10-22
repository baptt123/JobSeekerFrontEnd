import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatViewModel extends ChangeNotifier {
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = [];
  bool isConnected = false;

  void connect() {
    socket = IO.io('http://192.168.67.109:3000', {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) {
      isConnected = true;
      notifyListeners();
    });

    socket.onDisconnect((_) {
      isConnected = false;
      notifyListeners();
    });

    socket.on('new_message_1', (data) { // demo receiverId = 1
      messages.add(data);
      notifyListeners();
    });
  }

  void sendMessage(int senderId, int receiverId, String content) {
    if (!isConnected) {
      // offline: cache tạm
      messages.add({'senderId': senderId, 'receiverId': receiverId, 'content': content, 'offline': true});
      notifyListeners();
    } else {
      socket.emit('send_message', {'senderId': senderId, 'receiverId': receiverId, 'content': content});
    }
  }

  void markAsRead(int messageId) {
    socket.emit('mark_as_read', {'messageId': messageId});
  }

  void disposeSocket() {
    socket.dispose();
  }
}
