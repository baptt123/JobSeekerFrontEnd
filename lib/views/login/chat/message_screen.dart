import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/messages_view_model.dart';
import '../../../widgets/login/chat/message_tile.dart';



class MessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<MessagesViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Messages')),
      body: ListView.builder(
        itemCount: vm.messages.length,
        itemBuilder: (context, index) {
          final msg = vm.messages[index];
          return MessageTile(message: msg);
        },
      ),
    );
  }
}
