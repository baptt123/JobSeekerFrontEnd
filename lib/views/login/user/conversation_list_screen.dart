import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/conversation_list_view_model.dart';
import 'message_screen.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class ConversationListScreen extends StatelessWidget {
  const ConversationListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConversationListViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Tin nhắn", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          actions: [
            IconButton(icon: const Icon(Icons.search, color: Colors.black54), onPressed: () {}),
          ],
        ),
        body: Consumer<ConversationListViewModel>(
          builder: (context, vm, _) {
            // 1. Loading
            if (vm.state == ConversationState.loading) {
              return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
            }

            // 2. Unauthorized
            if (vm.state == ConversationState.unauthorized) {
              return _buildStateWidget(
                icon: Icons.lock_outline,
                message: "Vui lòng đăng nhập để xem tin nhắn",
                buttonText: "Đăng nhập",
                onPressed: () => Navigator.pushNamed(context, '/login'),
              );
            }

            // 3. [CẬP NHẬT] Xử lý Lỗi
            if (vm.state == ConversationState.error) {
              return _buildStateWidget(
                icon: Icons.signal_wifi_bad,
                message: "Không tải được danh sách chat",
                subMessage: vm.error,
                buttonText: "Thử lại",
                onPressed: () => vm.fetchUsers(),
              );
            }

            // 4. Trống
            if (vm.users.isEmpty) {
              return _buildStateWidget(
                icon: Icons.chat_bubble_outline,
                message: "Chưa có cuộc trò chuyện nào",
                subMessage: "Hãy ứng tuyển hoặc nhắn tin cho nhà tuyển dụng ngay!",
              );
            }

            // 5. Danh sách
            return ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: vm.users.length,
              itemBuilder: (ctx, i) {
                final user = vm.users[i];
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MessageScreen(
                        otherUserId: user.id,
                        otherUserName: user.fullName,
                        otherUserAvatar: user.avatarUrl ?? '',
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kPrimaryColor.withOpacity(0.3), width: 2)),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.grey[100],
                                backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                                child: user.avatarUrl == null ? Text(user.fullName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)) : null,
                              ),
                            ),
                            Positioned(right: 2, bottom: 2, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))))
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(user.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            const Text("Nhấn để bắt đầu trò chuyện...", style: TextStyle(fontSize: 14, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ]),
                        ),
                        const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStateWidget({required IconData icon, required String message, String? subMessage, String? buttonText, VoidCallback? onPressed}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 60, color: kPrimaryColor),
          ),
          const SizedBox(height: 24),
          Text(message, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          if (subMessage != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(subMessage, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            ),
          ],
          if (buttonText != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(buttonText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ]
        ],
      ),
    );
  }
}