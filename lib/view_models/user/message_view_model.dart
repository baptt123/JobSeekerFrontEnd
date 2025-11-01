// view_models/chat/chat_view_model.dart
import 'dart:io'; //
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/message-entity.dart';
import '../../services/image_upload_service.dart';
import '../../services/message_service.dart';

class MessageViewModel extends ChangeNotifier {
  MessageService? _chatService;
  final int otherUserId; // ID của người đang chat cùng
  final String otherUserName;
  final String otherUserAvatar;

  // Services
  final ImageUploadService _uploadService = ImageUploadService();
  final ImagePicker _picker = ImagePicker();

  int? _currentUserId; // ID của người dùng hiện tại (lấy từ socket)
  int? get currentUserId => _currentUserId;

  List<MessageEntity> _messages = [];
  List<MessageEntity> get messages => _messages;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  MessageViewModel({
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
  }) {
    _init();
  }

  void _init() {
    _chatService = MessageService(
      onUserConnected: (userId) {
        _currentUserId = userId;
        // Khi đã biết user ID, tải lịch sử chat
        _chatService?.loadConversation(otherUserId);
      },
      onMessageReceived: (message) {
        // Chỉ thêm tin nhắn nếu nó thuộc về cuộc hội thoại này
        if (message.senderId == otherUserId) {
          _messages.add(message);
          notifyListeners();
          // Tự động đánh dấu đã đọc
          _chatService?.markAsRead(otherUserId);
        }
      },
      onMessageSentConfirmed: (confirmedMessage) {
        // Cập nhật tin nhắn tạm (pending) bằng tin nhắn thật từ server
        // Tìm tin nhắn tạm
        final index = _messages.indexWhere((m) =>
        m.status == MessageStatus.pending &&
            (
                // Khớp tin nhắn text
                (m.messageType == 'text' && m.content == confirmedMessage.content) ||
                    // Khớp tin nhắn ảnh (khi tin nhắn ảnh được xác nhận)
                    (m.messageType == 'image' && confirmedMessage.messageType == 'image')
            )
        );

        if (index != -1) {
          // Nếu là ảnh, tin nhắn tạm đang giữ link local
          // Giờ cập nhật nó với link cloudinary từ server
          _messages[index] = confirmedMessage;
          notifyListeners();
        }
      },
      onConversationLoaded: (history) {
        _messages = history;
        _isLoading = false;
        notifyListeners();
        // Đánh dấu đã đọc tất cả tin nhắn
        _chatService?.markAsRead(otherUserId);
      },
    );
    _chatService?.connect();
  }

  /// Gửi tin nhắn dạng văn bản
  void sendTextMessage(String content) {
    if (content.trim().isEmpty || _currentUserId == null) return;

    // 1. Tạo tin nhắn tạm (Optimistic UI)
    final pendingMessage = MessageEntity.pendingText(
      senderId: _currentUserId!,
      receiverId: otherUserId,
      content: content,
    );
    _messages.add(pendingMessage);
    notifyListeners();

    // 2. Gửi DTO hoàn chỉnh qua socket
    _chatService?.sendMessage({
      'receiver_id': otherUserId,
      'content': content,
      'message_type': 'text',
    });
  }

  /// Gửi tin nhắn dạng hình ảnh
  Future<void> sendImageMessage() async {
    if (_currentUserId == null) return;

    try {
      // 1. Chọn ảnh
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final File imageFile = File(pickedFile.path);

      // 2. Hiển thị ảnh tạm (Optimistic UI)
      final pendingImage = MessageEntity.pendingImage(
        senderId: _currentUserId!,
        receiverId: otherUserId,
        localImagePath: imageFile.path, // Dùng path local để hiển thị
      );
      _messages.add(pendingImage);
      notifyListeners();

      // 3. Upload ảnh lên Cloudinary
      final String? imageUrl = await _uploadService.uploadImage(imageFile);

      if (imageUrl != null) {
        // 4. Gửi sự kiện socket với URL Cloudinary
        _chatService?.sendMessage({
          'receiver_id': otherUserId,
          'image_url': imageUrl,
          'message_type': 'image',
          'content': null, // Không có content
        });
      } else {
        // 5. Xử lý lỗi upload
        throw Exception('Upload ảnh thất bại');
      }
    } catch (e) {
      // Xử lý lỗi (upload hoặc chọn ảnh)
      // Tìm tin nhắn tạm và đánh dấu là failed
      final index = _messages.lastIndexWhere((m) => m.status == MessageStatus.pending && m.messageType == 'image');
      if (index != -1) {
        _messages[index].status = MessageStatus.failed;
        notifyListeners();
      }
      print("Lỗi gửi ảnh: $e");
    }
  }

  @override
  void dispose() {
    _chatService?.disconnect();
    super.dispose();
  }
}