// lib/view_models/user/message_view_model.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // [IMPORT] Thêm storage

import '../../models/message-entity.dart';
import '../../services/image_upload_service.dart';
import '../../services/message_service.dart';

class MessageViewModel extends ChangeNotifier {
  MessageService? _chatService;
  final int otherUserId;
  final String otherUserName;
  final String otherUserAvatar;

  // Services
  final ImageUploadService _uploadService = ImageUploadService();
  final ImagePicker _picker = ImagePicker();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(); // [UPDATE] Khai báo storage

  int? _currentUserId;
  int? get currentUserId => _currentUserId;

  List<MessageEntity> _messages = [];
  List<MessageEntity> get messages => _messages;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // [UPDATE] Thêm trạng thái Guest
  bool _isGuest = false;
  bool get isGuest => _isGuest;

  MessageViewModel({
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
  }) {
    _checkLoginAndInit(); // [UPDATE] Đổi tên hàm init
  }

  // [UPDATE] Kiểm tra đăng nhập trước khi kết nối socket
  Future<void> _checkLoginAndInit() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) {
      _isGuest = true;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isGuest = false;
    _initSocket();
  }

  void _initSocket() {
    _chatService = MessageService(
      onUserConnected: (userId) {
        _currentUserId = userId;
        _chatService?.loadConversation(otherUserId);
      },
      onMessageReceived: (message) {
        if (message.senderId == otherUserId) {
          _messages.add(message);
          notifyListeners();
          _chatService?.markAsRead(otherUserId);
        }
      },
      onMessageSentConfirmed: (confirmedMessage) {
        final index = _messages.indexWhere((m) =>
        m.status == MessageStatus.pending &&
            ((m.messageType == 'text' && m.content == confirmedMessage.content) ||
                (m.messageType == 'image' && confirmedMessage.messageType == 'image') ||
                (m.messageType == 'sticker' && confirmedMessage.messageType == 'sticker') ||
                (m.messageType == 'file' && confirmedMessage.messageType == 'file')));

        if (index != -1) {
          _messages[index] = confirmedMessage;
          notifyListeners();
        }
      },
      onConversationLoaded: (history) {
        _messages = history;
        _isLoading = false;
        notifyListeners();
        _chatService?.markAsRead(otherUserId);
      },
    );
    _chatService?.connect();
  }

  void sendTextMessage(String content) {
    if (content.trim().isEmpty || _currentUserId == null) return;

    final pendingMessage = MessageEntity.pendingText(
      senderId: _currentUserId!,
      receiverId: otherUserId,
      content: content,
    );
    _messages.add(pendingMessage);
    notifyListeners();

    _chatService?.sendMessage({
      'receiver_id': otherUserId,
      'content': content,
      'message_type': 'text',
    });
  }

  Future<void> sendImageMessage() async {
    if (_currentUserId == null) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final File imageFile = File(pickedFile.path);

      final pendingImage = MessageEntity.pendingImage(
        senderId: _currentUserId!,
        receiverId: otherUserId,
        localImagePath: imageFile.path,
      );
      _messages.add(pendingImage);
      notifyListeners();

      final String? imageUrl = await _uploadService.uploadImage(imageFile);

      if (imageUrl != null) {
        _chatService?.sendMessage({
          'receiver_id': otherUserId,
          'image_url': imageUrl,
          'message_type': 'image',
          'content': null,
        });
      } else {
        throw Exception('Upload ảnh thất bại');
      }
    } catch (e) {
      _handleUploadError('image');
      print("Lỗi gửi ảnh: $e");
    }
  }

  void sendSticker(String stickerUrl) {
    if (_currentUserId == null) return;

    final pendingMessage = MessageEntity(
      senderId: _currentUserId!,
      receiverId: otherUserId,
      content: 'Sticker',
      sentAt: DateTime.now(),
      status: MessageStatus.pending,
      messageType: 'sticker',
      imageUrl: stickerUrl,
    );
    _messages.add(pendingMessage);
    notifyListeners();

    _chatService?.sendMessage({
      'receiver_id': otherUserId,
      'image_url': stickerUrl,
      'message_type': 'sticker',
      'content': 'Sticker',
    });
  }

  Future<void> sendFileMessage() async {
    if (_currentUserId == null) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;

        final String? fileUrl = await _uploadService.uploadImage(file);

        if (fileUrl != null) {
          _chatService?.sendMessage({
            'receiver_id': otherUserId,
            'image_url': fileUrl,
            'message_type': 'file',
            'content': fileName,
          });
        }
      }
    } catch (e) {
      print("Lỗi gửi file: $e");
    }
  }

  void _handleUploadError(String type) {
    final index = _messages.lastIndexWhere((m) => m.status == MessageStatus.pending && m.messageType == type);
    if (index != -1) {
      _messages[index].status = MessageStatus.failed;
      notifyListeners();
    }
  }

  // [UPDATE] Hàm reload khi người dùng đăng nhập xong
  void refresh() {
    _checkLoginAndInit();
  }

  @override
  void dispose() {
    _chatService?.disconnect();
    super.dispose();
  }
}