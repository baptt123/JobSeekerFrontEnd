import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/user/chat_view_model.dart';
import '../../widgets/login/chat/chat_input.dart';
import '../../widgets/login/chat/chat_message_list.dart';


class ChatScreen extends StatelessWidget {
  final int otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy ViewModel từ Provider
    final vm = Provider.of<ChatViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(otherUserName),
      ),
      body: Column(
        children: const [
          Expanded(child: ChatMessageList()),
          ChatInput(),
        ],
      ),
    );
  }
}
