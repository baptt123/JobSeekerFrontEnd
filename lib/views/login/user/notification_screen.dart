import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../dto/notification_dto.dart';
import '../../../view_models/user/notification_view_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy ViewModel từ Provider
    final viewModel = context.watch<NotificationViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.black),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildNotificationList(viewModel.groupedNotifications),
    );
  }

  Widget _buildNotificationList(Map<String, List<NotificationDto>> grouped) {
    final groupKeys = grouped.keys.toList();

    return ListView.builder(
      itemCount: groupKeys.length,
      itemBuilder: (context, index) {
        final groupName = groupKeys[index];
        final notifications = grouped[groupName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 16.0, bottom: 10.0),
              child: Text(
                groupName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            // Vẽ danh sách notification cho group này
            ...notifications.map((notif) => _buildNotificationTile(notif)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildNotificationTile(NotificationDto notification) {
    return ListTile(
      leading: _buildIcon(notification.type),
      title: Text(
        notification.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        notification.message,
        style: const TextStyle(color: Colors.grey),
      ),
      // Bạn có thể thêm logic hiển thị chấm tròn "chưa đọc"
      trailing: !notification.isRead
          ? Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      )
          : null,
    );
  }

  // Helper để lấy icon dựa trên type
  Widget _buildIcon(NotificationType type) {
    IconData iconData;
    Color iconColor;
    Color backgroundColor;

    switch (type) {
      case NotificationType.jobApplied:
        iconData = Icons.work_outline;
        iconColor = Colors.blue;
        backgroundColor = Colors.blue.withOpacity(0.1);
        break;
      case NotificationType.accountVerified:
        iconData = Icons.check_circle_outline;
        iconColor = Colors.green;
        backgroundColor = Colors.green.withOpacity(0.1);
        break;
      case NotificationType.profileUpdated:
        iconData = Icons.person_outline;
        iconColor = Colors.orange;
        backgroundColor = Colors.orange.withOpacity(0.1);
        break;
      default:
        iconData = Icons.notifications_none;
        iconColor = Colors.grey;
        backgroundColor = Colors.grey.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor),
    );
  }
}