import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/message-entity.dart';
import '../../../view_models/user/message_view_model.dart';
import '../../../utils/app_colors.dart';

class MessageScreen extends StatelessWidget {
  final int otherUserId;
  final String otherUserName;
  final String otherUserAvatar;

  const MessageScreen({Key? key, required this.otherUserId, required this.otherUserName, required this.otherUserAvatar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MessageViewModel(otherUserId: otherUserId, otherUserName: otherUserName, otherUserAvatar: otherUserAvatar),
      child: Consumer<MessageViewModel>(
        builder: (context, vm, _) => Scaffold(
          appBar: AppBar(
            title: Row(children: [
              CircleAvatar(radius: 16, backgroundImage: otherUserAvatar.isNotEmpty ? NetworkImage(otherUserAvatar) : null),
              const SizedBox(width: 10),
              Text(otherUserName, style: const TextStyle(fontSize: 16)),
            ]),
            actions: [IconButton(icon: const Icon(Icons.videocam), onPressed: () {})],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.messages.length,
                  itemBuilder: (_, i) {
                    final msg = vm.messages[vm.messages.length - 1 - i];
                    final isMe = msg.senderId == vm.currentUserId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primary : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                            bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(16),
                          ),
                        ),
                        child: Text(msg.content, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                      ),
                    );
                  },
                ),
              ),
              _buildInput(context, vm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context, MessageViewModel vm) {
    final controller = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (val) { vm.sendTextMessage(val); controller.clear(); },
            ),
          ),
          IconButton(icon: const Icon(Icons.send, color: AppColors.primary), onPressed: () { vm.sendTextMessage(controller.text); controller.clear(); }),
        ],
      ),
    );
  }
}