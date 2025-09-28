import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../view_models/user/extra_view/messages_view_model.dart';
import '../../../../../widgets/login/extra_widget/chat/message_tile.dart';



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
