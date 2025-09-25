class MessageEntity {
  final int messageId;
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime sentAt;

  MessageEntity({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
  });

  factory MessageEntity.fromJson(Map<String, dynamic> json) => MessageEntity(
    messageId: json['message_id'],
    senderId: json['sender_id'],
    receiverId: json['receiver_id'],
    content: json['content'],
    sentAt: DateTime.parse(json['sent_at']),
  );

  Map<String, dynamic> toJson() => {
    'message_id': messageId,
    'sender_id': senderId,
    'receiver_id': receiverId,
    'content': content,
    'sent_at': sentAt.toIso8601String(),
  };
}
