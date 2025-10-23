// lib/viewmodels/chat_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/models/message-entity.dart';
import 'package:job_seeker_frontend/services/chat_service.dart';
import '../../services/socket_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _api = ChatService();
  final SocketService _socket = SocketService();

  List<MessageEntity> messages = [];
  bool isLoading = false;

  void connect(int userId) {
    _socket.connect(userId);
  }

  Future<void> loadMessages(int userA, int userB) async {
    isLoading = true;
    notifyListeners();
    try {
      messages = await _api.getConversation(userA, userB);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void sendMessage(int senderId, int receiverId, String content) {
    _socket.sendMessage(senderId, receiverId, content);
  }

  void listenMessages() {
    _socket.onNewMessage((msg) {
      messages.add(msg);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
