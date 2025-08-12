import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final Map<String, dynamic> message;
  const MessageTile({required this.message});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(/* ... */),
      title: Text(message['name']),
      subtitle: Text(message['snippet']),
      trailing: Text(message['time']),
      onTap: () {
        // open chat
      },
    );
  }
}
