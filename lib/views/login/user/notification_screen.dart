// lib/views/login/user/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/notification_view_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // [UPDATE] Dùng create: (_) => NotificationViewModel() ở đây nếu chưa có Provider toàn cục
    // Tuy nhiên tốt nhất là NotificationViewModel được tạo ở main.dart để giữ trạng thái
    // Nếu tạo mới mỗi lần vào màn hình, badge count ở Home sẽ không đồng bộ
    // GIẢ ĐỊNH: Bạn đã khai báo NotificationViewModel trong main.dart

    // Nếu chưa khai báo global, hãy dùng ChangeNotifierProvider.value hoặc tạo mới:
    // return ChangeNotifierProvider(create: (_) => NotificationViewModel()..initialize(), ...);

    // Dưới đây sử dụng Consumer trực tiếp (giả định đã có Provider ở trên cây widget)
    // Nếu chưa có, bạn bọc Scaffold bằng ChangeNotifierProvider như code cũ.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Báo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {

          // 1. Chưa đăng nhập
          if (viewModel.state == NotificationState.unauthorized) {
            return _buildGuestView(context, viewModel);
          }

          // 2. Loading
          if (viewModel.state == NotificationState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 3. Lỗi
          if (viewModel.state == NotificationState.error) {
            return Center(child: Text('Lỗi: ${viewModel.errorMessage}'));
          }

          // 4. Rỗng
          if (viewModel.notifications.isEmpty) {
            return const Center(child: Text('Bạn chưa có thông báo nào.'));
          }

          // 5. Danh sách
          return RefreshIndicator(
            onRefresh: viewModel.fetchNotifications,
            child: ListView.separated(
              itemCount: viewModel.notifications.length,
              separatorBuilder: (ctx, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = viewModel.notifications[index];
                return Container(
                  color: notification.isRead
                      ? Colors.white
                      : const Color(0xFFE0F2F1), // Highlight tin chưa đọc
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF00C89C).withOpacity(0.1),
                      child: Icon(
                        Icons.notifications,
                        color: const Color(0xFF00C89C),
                      ),
                    ),
                    title: Text(
                      notification.title ?? 'Thông báo hệ thống',
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notification.message ?? ''),
                        const SizedBox(height: 6),
                        Text(
                          notification.createdAt.toString().substring(0, 16), // Format sơ bộ
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () {
                      // viewModel.markAsRead(notification.notificationId);
                      // TODO: Điều hướng chi tiết
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Widget hiển thị cho khách
  Widget _buildGuestView(BuildContext context, NotificationViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            const Text(
              "Vui lòng đăng nhập",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Đăng nhập để xem các thông báo mới nhất về việc làm.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login').then((_) {
                  vm.initialize(); // Refresh lại khi login xong
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C89C),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Đăng nhập ngay", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}