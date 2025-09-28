import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onDelete;

  const NotificationTile({required this.notification, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Image.asset(notification['icon']), // e.g. assets/google.png
        title: Text(notification['title']),
        subtitle: Text(notification['subtitle']),
        trailing: TextButton(onPressed: onDelete, child: Text('Delete', style: TextStyle(color: Colors.red))),
      ),
    );
  }
}
