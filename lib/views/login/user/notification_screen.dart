import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/notification_view_model.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Sử dụng màu nền sáng cho đồng bộ với thiết kế mới
    final backgroundColor = Colors.grey[50];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Thông Báo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        // Đã bỏ action button "Đánh dấu tất cả đã đọc"
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, vm, _) {
          // 1. Loading
          if (vm.state == NotificationState.loading) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          // 2. Error
          if (vm.state == NotificationState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  const Text("Không tải được thông báo"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.fetchNotifications(),
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                    child: const Text("Tải lại", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          // 3. Empty
          if (vm.notifications.isEmpty) return _buildEmptyState(context);

          // 4. List Data
          return RefreshIndicator(
            onRefresh: vm.fetchNotifications,
            color: kPrimaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.notifications.length,
              itemBuilder: (context, index) {
                final noti = vm.notifications[index];

                // Hiển thị đồng nhất, không phân biệt đã đọc/chưa đọc bằng màu nền
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_rounded,
                          color: kPrimaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              noti.title ?? 'Thông báo mới',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              noti.message ?? '',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${noti.createdAt.day}/${noti.createdAt.month} lúc ${noti.createdAt.hour}:${noti.createdAt.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const Text("Không có thông báo nào", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}