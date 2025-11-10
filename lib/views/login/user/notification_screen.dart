// lib/views/login/user/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/notification_view_model.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Thông Báo'),
          actions: [
            // Nút để test
            Consumer<NotificationViewModel>(
              builder: (context, viewModel, child) {
                return IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _showSendTestDialog(context, viewModel);
                  },
                );
              },
            )
          ],
        ),
        body: Consumer<NotificationViewModel>(
          builder: (context, viewModel, child) {
            // Hiển thị loading
            if (viewModel.state == NotificationState.Loading && viewModel.notifications.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            // Hiển thị lỗi
            if (viewModel.state == NotificationState.Error) {
              return Center(child: Text('Lỗi: ${viewModel.errorMessage}'));
            }

            // Hiển thị danh sách rỗng
            if (viewModel.notifications.isEmpty) {
              return Center(child: Text('Bạn chưa có thông báo nào.'));
            }

            // Hiển thị danh sách thông báo
            return RefreshIndicator(
              onRefresh: viewModel.fetchNotifications,
              child: ListView.builder(
                itemCount: viewModel.notifications.length,
                itemBuilder: (context, index) {
                  final notification = viewModel.notifications[index];
                  return ListTile(
                    leading: Icon(
                      notification.isRead ?? false
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                      color: notification.isRead ?? false
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                    ),
                    title: Text(notification.title ?? 'Không có tiêu đề'),
                    subtitle: Text(notification.message ?? 'Không có nội dung'),
                    trailing: Text(
                      // Format thời gian (cần intl package)
                      notification.createdAt?.toString() ?? '',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // Dialog để gửi thông báo test
  void _showSendTestDialog(BuildContext context, NotificationViewModel viewModel) {
    final titleController = TextEditingController(text: "Thông Báo Test");
    final bodyController = TextEditingController(text: "Nội dung test từ app 🚀");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Gửi Thông Báo Test'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Tiêu đề'),
            ),
            TextField(
              controller: bodyController,
              decoration: InputDecoration(labelText: 'Nội dung'),
            ),
            SizedBox(height: 10),
            Text(
              'Token: ${viewModel.deviceToken ?? "Đang tải..."}',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Hủy'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: Text('Gửi'),
            onPressed: () async {
              await viewModel.sendTestNotification(
                titleController.text,
                bodyController.text,
              );
              Navigator.of(ctx).pop(); // Đóng dialog sau khi gửi
            },
          ),
        ],
      ),
    );
  }
}