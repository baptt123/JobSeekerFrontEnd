import 'package:flutter/material.dart';

class ChatViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> messages = [
    // example: {'text': 'Hello', 'isMe': false}
  ];
  final TextEditingController controller = TextEditingController();

  void sendMessage() {
    if (controller.text.isNotEmpty) {
      messages.add({'text': controller.text, 'isMe': true});
      controller.clear();
      notifyListeners();
    }
  }
}
