import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/notification_view_model.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thông Báo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        actions: [
          Consumer<NotificationViewModel>(
            builder: (context, vm, _) {
              if (vm.unreadCount == 0) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.done_all, color: kPrimaryColor),
                tooltip: "Đánh dấu tất cả đã đọc",
                onPressed: () async {
                  await context.read<NotificationViewModel>().markAllAsRead();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã đánh dấu tất cả là đã đọc"), backgroundColor: Colors.green),
                    );
                  }
                },
              );
            },
          )
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, vm, _) {
          // 1. Loading
          if (vm.state == NotificationState.loading) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          // 2. [CẬP NHẬT] Xử lý Lỗi
          if (vm.state == NotificationState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  const Text("Không tải được thông báo", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.fetchNotifications(), // Thử lại
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: Colors.white),
                    child: const Text("Tải lại"),
                  )
                ],
              ),
            );
          }

          // 3. Trống
          if (vm.notifications.isEmpty) return _buildEmptyState();

          // 4. Danh sách
          return RefreshIndicator(
            onRefresh: vm.fetchNotifications,
            color: kPrimaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.notifications.length,
              itemBuilder: (context, index) {
                final noti = vm.notifications[index];
                // ... (Phần UI Item giữ nguyên như code cũ)
                return GestureDetector(
                  onTap: () {
                    if (!noti.isRead) vm.markAsRead(noti.notificationId);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: noti.isRead ? Colors.white : kPrimaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: noti.isRead ? Colors.grey[100] : Colors.white, shape: BoxShape.circle),
                          child: Icon(Icons.notifications_rounded, color: noti.isRead ? Colors.grey : kPrimaryColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(noti.title ?? 'Thông báo mới', style: TextStyle(fontWeight: noti.isRead ? FontWeight.w600 : FontWeight.bold, fontSize: 15, color: Colors.black87)),
                            const SizedBox(height: 6),
                            Text(noti.message ?? '', style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4)),
                            const SizedBox(height: 8),
                            Text("${noti.createdAt.day}/${noti.createdAt.month} lúc ${noti.createdAt.hour}:${noti.createdAt.minute.toString().padLeft(2, '0')}", style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                          ]),
                        ),
                        if (!noti.isRead)
                          Container(margin: const EdgeInsets.only(left: 8, top: 5), width: 10, height: 10, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle))
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle), child: const Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey)),
          const SizedBox(height: 20),
          const Text("Không có thông báo nào", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}