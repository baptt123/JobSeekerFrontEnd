import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/chat_view_model.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, vm, child) {
        final msgs = vm.messages;
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: msgs.length,
          itemBuilder: (context, idx) {
            final m = msgs[idx];
            final isMe = m.senderId == vm.currentUserId;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blueAccent : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      m.content,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
