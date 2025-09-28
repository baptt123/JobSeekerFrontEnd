import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../view_models/user/extra_view/chat_view_model.dart';
import '../../../../../widgets/login/extra_widget/chat/chat_bubble.dart';


class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ChatViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: vm.messages.length,
              itemBuilder: (context, index) {
                final msg = vm.messages[index];
                return ChatBubble(message: msg);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: vm.controller,
                    decoration: InputDecoration(hintText: 'Write your message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => vm.sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
