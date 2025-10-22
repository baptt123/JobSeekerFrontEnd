import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/chat_view_model.dart';

class ChatScreen extends StatelessWidget {
  final int senderId;
  final int receiverId;

  const ChatScreen({super.key, required this.senderId, required this.receiverId});

  @override
  Widget build(BuildContext context) {
    final chatVM = context.watch<ChatViewModel>();
    final msgCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatVM.messages.length,
              itemBuilder: (context, index) {
                final msg = chatVM.messages[index];
                return ListTile(
                  title: Text(msg['content']),
                  subtitle: Text(msg['offline'] == true ? 'Đang chờ gửi...' : ''),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(controller: msgCtrl, decoration: const InputDecoration(hintText: 'Nhập tin nhắn')),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  chatVM.sendMessage(senderId, receiverId, msgCtrl.text);
                  msgCtrl.clear();
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
