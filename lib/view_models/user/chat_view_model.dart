import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:job_seeker_frontend/models/message-entity.dart';

import '../../dto/create_message_dto.dart';
import '../../dto/message_response_dto.dart';
import '../../services/web_socket_service.dart';


class ChatViewModel extends ChangeNotifier {
  final Dio dio;
  final WebSocketService ws;
  final int currentUserId;
  final int otherUserId;

  List<MessageEntity> messages = [];
  StreamSubscription? _wsSub;

  ChatViewModel({
    required this.dio,
    required this.ws,
    required this.currentUserId,
    required this.otherUserId,
  }) {
    _init();
  }

  Future<void> _init() async {
    ws.connect();

    _wsSub = ws.messagesStream.listen((data) {
      final dto = MessageResponseDto.fromJson(data);
      final msg = MessageEntity.fromDto(dto);

      if ((msg.senderId == currentUserId && msg.receiverId == otherUserId) ||
          (msg.senderId == otherUserId && msg.receiverId == currentUserId)) {
        messages.add(msg);
        notifyListeners();
      }
    });

    await loadHistory();
    await markAsRead();
  }

  Future<void> loadHistory({int limit = 200}) async {
    final res = await dio.get(
      '/messages/conversation/$otherUserId',
      queryParameters: {'limit': limit},
    );

    final data = res.data as List;
    messages = data
        .map((e) => MessageEntity.fromDto(MessageResponseDto.fromJson(e)))
        .toList();
    notifyListeners();
  }

  Future<void> send(String content) async {
    final dto = CreateMessageDto(
      senderId: currentUserId,
      receiverId: otherUserId,
      content: content,
    );

    // Optimistic update cho UI
    messages.add(MessageEntity(
      senderId: currentUserId,
      receiverId: otherUserId,
      content: content,
      sentAt: DateTime.now(),
    ));
    notifyListeners();

    ws.sendMessage(dto.toJson());
  }

  Future<void> markAsRead() async {
    try {
      await dio.patch('/messages/mark-read/$otherUserId');
    } catch (_) {}
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    ws.dispose();
    super.dispose();
  }
}
