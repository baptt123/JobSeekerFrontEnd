import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/notification_view_model.dart';
import '../../../widgets/login/notification/notification_tile.dart';


class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<NotificationsViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: ListView.builder(
        itemCount: vm.notifications.length,
        itemBuilder: (context, index) {
          final item = vm.notifications[index];
          return NotificationTile(notification: item, onDelete: () => vm.deleteNotification(index));
        },
      ),
    );
  }
}
