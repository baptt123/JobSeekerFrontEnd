// views/chat/conversation_list_screen.dart (TẠO FILE MỚI)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/conversation_list_view_model.dart';
import 'message_screen.dart'; // Import màn hình chat CHI TIẾT

class ConversationListScreen extends StatelessWidget {
  const ConversationListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConversationListViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tin nhắn'),
        ),
        body: Consumer<ConversationListViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.error.isNotEmpty) {
              return Center(child: Text(vm.error));
            }

            if (vm.users.isEmpty) {
              return const Center(child: Text('Không tìm thấy user nào.'));
            }

            // Hiển thị danh sách
            return ListView.builder(
              itemCount: vm.users.length,
              itemBuilder: (context, index) {
                final user = vm.users[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                        ? NetworkImage(user.avatarUrl!)
                        : const AssetImage('assets/icon/default_avatar.png') as ImageProvider, // Thêm avatar mặc định
                  ),
                  title: Text(user.fullName),
                  subtitle: Text(user.email),
                  onTap: () {
                    // ✅ ĐÂY LÀ PHẦN QUAN TRỌNG NHẤT
                    // Điều hướng động, không còn fix cứng
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageScreen(
                          otherUserId: user.id, // ID động
                          otherUserName: user.fullName, // Tên động
                          otherUserAvatar: user.avatarUrl ?? '', // Avatar động
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}