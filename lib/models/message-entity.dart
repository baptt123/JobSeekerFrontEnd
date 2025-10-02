import '../dto/message_response_dto.dart';

class MessageEntity {
  final int? messageId;
  final int senderId;
  final int receiverId;
  final String content;
  final bool isRead;
  final DateTime sentAt;

  MessageEntity({
    this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.isRead = false,
    DateTime? sentAt,
  }) : sentAt = sentAt ?? DateTime.now();

  // Convert từ DTO backend sang domain model
  factory MessageEntity.fromDto(MessageResponseDto dto) {
    return MessageEntity(
      messageId: dto.messageId,
      senderId: dto.senderId,
      receiverId: dto.receiverId,
      content: dto.content,
      isRead: dto.isRead,
      sentAt: dto.sentAt,
    );
  }
}
