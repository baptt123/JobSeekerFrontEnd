class MessageResponseDto {
  final int messageId;
  final int senderId;
  final int receiverId;
  final String content;
  final bool isRead;
  final DateTime sentAt;

  MessageResponseDto({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.sentAt,
  });

  factory MessageResponseDto.fromJson(Map<String, dynamic> json) {
    return MessageResponseDto(
      messageId: json['message_id'] as int,
      senderId: json['sender_id'] as int,
      receiverId: json['receiver_id'] as int,
      content: json['content'] as String,
      isRead: json['is_read'] as bool,
      sentAt: DateTime.parse(json['sent_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message_id": messageId,
      "sender_id": senderId,
      "receiver_id": receiverId,
      "content": content,
      "is_read": isRead,
      "sent_at": sentAt.toIso8601String(),
    };
  }
}
