// lib/views/user/chat_view_screen.dart
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/models/user-entity.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/chat_view_model.dart';

class ChatViewScreen extends StatefulWidget {
  final UserEntity currentUser;
  final int peerId;

  const ChatViewScreen({
    super.key,
    required this.currentUser,
    required this.peerId,
  });

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = context.read<ChatViewModel>();
    vm.connect(widget.currentUser.userId);
    vm.loadMessages(widget.currentUser.userId, widget.peerId);
    vm.listenMessages();
  }

  void _send(BuildContext context) {
    if (_ctrl.text.isEmpty) return;
    final vm = context.read<ChatViewModel>();
    vm.sendMessage(widget.currentUser.userId, widget.peerId, _ctrl.text);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();

    return Scaffold(
      appBar: AppBar(title: Text("Chat với user ${widget.peerId}")),
      body: Column(
        children: [
          if (vm.isLoading)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: ListView.builder(
              itemCount: vm.messages.length,
              itemBuilder: (_, i) {
                final m = vm.messages[i];
                final isMine = m.senderId == widget.currentUser.userId;
                return Align(
                  alignment:
                  isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMine ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(m.content),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(
                    hintText: "Nhập tin nhắn...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _send(context),
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
