import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_seeker_frontend/view_models/user/notification_view_model.dart';

// Nếu bạn đã có AppColors trong utils, hãy import nó thay vì khai báo lại
// import 'package:job_seeker_frontend/utils/app_colors.dart';
const Color kPrimaryColor = Color(0xFF6C63FF);

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin theme hiện tại để xử lý logic màu sắc custom
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // BỎ backgroundColor cứng, tự lấy từ Theme
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Thông Báo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            // Màu chữ tự động theo Theme (Đen ở Light, Trắng ở Dark)
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
        // AppBar dùng màu của Theme, bỏ gán cứng
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        // BackButton tự động lấy màu từ IconTheme/AppBarTheme
        leading: const BackButton(),
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
                      const SnackBar(
                        content: Text("Đã đánh dấu tất cả là đã đọc"),
                        backgroundColor: Colors.green,
                      ),
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

          // 2. Xử lý Lỗi
          if (vm.state == NotificationState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text("Không tải được thông báo", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.fetchNotifications(),
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: Colors.white),
                    child: const Text("Tải lại"),
                  )
                ],
              ),
            );
          }

          // 3. Trống
          if (vm.notifications.isEmpty) return _buildEmptyState(context);

          // 4. Danh sách
          return RefreshIndicator(
            onRefresh: vm.fetchNotifications,
            color: kPrimaryColor,
            backgroundColor: theme.cardTheme.color, // Màu nền quay loading
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.notifications.length,
              itemBuilder: (context, index) {
                final noti = vm.notifications[index];

                // --- XỬ LÝ MÀU ITEM ---
                // Nếu ĐÃ ĐỌC: Dùng màu Card (Trắng hoặc Xám tối)
                // Nếu CHƯA ĐỌC: Dùng màu tím nhạt (Đậm hơn chút nếu ở Dark Mode để dễ đọc)
                final Color itemBgColor = noti.isRead
                    ? theme.cardTheme.color!
                    : kPrimaryColor.withOpacity(isDark ? 0.2 : 0.08);

                final Color borderColor = isDark ? Colors.white12 : Colors.grey.shade200;

                return GestureDetector(
                  onTap: () {
                    if (!noti.isRead) vm.markAsRead(noti.notificationId);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: itemBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Container
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            // Nền icon thay đổi theo trạng thái đọc
                              color: noti.isRead
                                  ? (isDark ? Colors.grey[800] : Colors.grey[100])
                                  : (isDark ? Colors.white10 : Colors.white),
                              shape: BoxShape.circle
                          ),
                          child: Icon(
                              Icons.notifications_rounded,
                              color: noti.isRead ? Colors.grey : kPrimaryColor,
                              size: 24
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    noti.title ?? 'Thông báo mới',
                                    style: TextStyle(
                                        fontWeight: noti.isRead ? FontWeight.w600 : FontWeight.bold,
                                        fontSize: 15,
                                        // Màu chữ tiêu đề tự động
                                        color: theme.textTheme.bodyLarge?.color
                                    )
                                ),
                                const SizedBox(height: 6),
                                Text(
                                    noti.message ?? '',
                                    style: TextStyle(
                                      // Màu chữ nội dung (dùng caption hoặc bodyMedium)
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                        fontSize: 13,
                                        height: 1.4
                                    )
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    "${noti.createdAt.day}/${noti.createdAt.month} lúc ${noti.createdAt.hour}:${noti.createdAt.minute.toString().padLeft(2, '0')}",
                                    style: TextStyle(fontSize: 11, color: Colors.grey[500])
                                ),
                              ]
                          ),
                        ),
                        if (!noti.isRead)
                          Container(
                              margin: const EdgeInsets.only(left: 8, top: 5),
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)
                          )
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

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Màu nền tròn icon empty
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  shape: BoxShape.circle
              ),
              child: const Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey)
          ),
          const SizedBox(height: 20),
          const Text("Không có thông báo nào", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}