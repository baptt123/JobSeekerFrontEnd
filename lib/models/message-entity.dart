// models/message_model.dart

enum MessageStatus { pending, sent, delivered, read, failed }

class MessageEntity {
  final int? messageId;
  final int senderId;
  final int receiverId;
  final String content; // Sẽ là "" nếu là ảnh
  final DateTime sentAt;
  bool isRead;
  MessageStatus status;

  // ✅ THÊM 2 TRƯỜNG MỚI
  final String? imageUrl;
  final String messageType; // 'text' hoặc 'image'

  MessageEntity({
    this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
    this.isRead = false,
    this.status = MessageStatus.sent,
    this.imageUrl, // ✅ Thêm vào constructor
    this.messageType = 'text', // ✅ Thêm vào constructor
  });

  // Factory để tạo từ JSON (khi nhận từ socket)
  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    return MessageEntity(
      messageId: json['message_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'] ?? '', // Xử lý null
      sentAt: DateTime.parse(json['sent_at']),
      isRead: json['is_read'] ?? false,
      status: MessageStatus.sent,
      // ✅ Lấy 2 trường mới từ JSON
      imageUrl: json['image_url'],
      messageType: json['message_type'] ?? 'text',
    );
  }

  // Tạo một tin nhắn văn bản tạm (chờ gửi)
  factory MessageEntity.pendingText({
    required int senderId,
    required int receiverId,
    required String content,
  }) {
    return MessageEntity(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      sentAt: DateTime.now(),
      status: MessageStatus.pending,
      messageType: 'text',
    );
  }

  // ✅ TẠO TIN NHẮN ẢNH TẠM (CHỜ UPLOAD)
  factory MessageEntity.pendingImage({
    required int senderId,
    required int receiverId,
    required String localImagePath, // Dùng để hiển thị ảnh tạm
  }) {
    return MessageEntity(
      senderId: senderId,
      receiverId: receiverId,
      content: '',
      sentAt: DateTime.now(),
      status: MessageStatus.pending,
      messageType: 'image',
      imageUrl: localImagePath, // Tạm thời dùng link local
    );
  }
}