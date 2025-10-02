class CreateMessageDto {
  final int senderId;
  final int receiverId;
  final String content;

  CreateMessageDto({
    required this.senderId,
    required this.receiverId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      "sender_id": senderId,
      "receiver_id": receiverId,
      "content": content,
    };
  }
}
