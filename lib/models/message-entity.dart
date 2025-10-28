class MessageEntity {
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime sentAt;

  MessageEntity({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
  });

  factory MessageEntity.fromJson(Map<String, dynamic> json) => MessageEntity(
    senderId: json['sender_id'],
    receiverId: json['receiver_id'],
    content: json['content'],
    sentAt: DateTime.parse(json['sent_at']),
  );
}
