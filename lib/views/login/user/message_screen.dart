// views/chat/message_screen.dart (Hoặc chat_screen.dart)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/message-entity.dart';
import '../../../view_models/user/message_view_model.dart';

class MessageScreen extends StatelessWidget {
  final int otherUserId;
  final String otherUserName;
  final String otherUserAvatar;

  const MessageScreen({
    Key? key,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MessageViewModel(
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserAvatar: otherUserAvatar,
      ),
      child: Consumer<MessageViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: _buildAppBar(context, vm),
            backgroundColor: Colors.white,
            body: Column(
              children: [
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    reverse: true, // Hiển thị từ dưới lên
                    itemCount: vm.messages.length,
                    itemBuilder: (context, index) {
                      // Sắp xếp lại để tin nhắn mới nhất ở dưới
                      final message =
                      vm.messages[vm.messages.length - 1 - index];
                      final bool isMe =
                          message.senderId == vm.currentUserId;
                      return _MessageBubble(
                        message: message,
                        isMe: isMe,
                        avatarUrl: vm.otherUserAvatar,
                      );
                    },
                  ),
                ),
                _buildMessageInput(context),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, MessageViewModel vm) {
    return AppBar(
      elevation: 1,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: (vm.otherUserAvatar.isNotEmpty)
                ? NetworkImage(vm.otherUserAvatar)
                : const AssetImage('assets/icon/default_avatar.png') as ImageProvider,
            radius: 20,
          ),
          const SizedBox(width: 12),
          Text(
            vm.otherUserName,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call_outlined, color: Colors.black54),
          onPressed: () { /* Xử lý gọi điện */ },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black54),
          onPressed: () { /* Xử lý thêm */ },
        ),
      ],
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    final vm = context.read<MessageViewModel>();
    final TextEditingController controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Nút gửi ảnh
            IconButton(
              icon: Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600),
              onPressed: () {
                vm.sendImageMessage(); // Gọi hàm gửi ảnh
              },
            ),
            // Ô nhập text
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Type something...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Nút gửi text
            IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              onPressed: () {
                vm.sendTextMessage(controller.text); // Gọi hàm gửi text
                controller.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// WIDGET BONG BÓNG TIN NHẮN (VĂN BẢN VÀ HÌNH ẢNH)
class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final String avatarUrl;

  const _MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.avatarUrl,
  }) : super(key: key);

  /// Quyết định nội dung bong bóng chat (Text hoặc Image)
  Widget _buildContent() {
    // 1. NẾU LÀ TIN NHẮN ẢNH
    if (message.messageType == 'image' && message.imageUrl != null) {
      // Kiểm tra xem đây là ảnh local (đang chờ upload) hay ảnh mạng
      bool isLocalFile = message.status == MessageStatus.pending;

      return Container(
        constraints: const BoxConstraints(
          maxWidth: 250, // Chiều rộng tối đa cho ảnh
          maxHeight: 350, // Chiều cao tối đa cho ảnh
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: isLocalFile
          // Hiển thị ảnh tạm (chờ upload) từ file local
              ? Image.file(
            File(message.imageUrl!),
            fit: BoxFit.cover,
          )
          // Hiển thị ảnh đã upload (từ Cloudinary)
              : Image.network(
            message.imageUrl!,
            fit: BoxFit.cover,
            // Hiển thị loading
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                width: 200,
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            // Hiển thị lỗi
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
            },
          ),
        ),
      );
    }

    // 2. NẾU LÀ TIN NHẮN VĂN BẢN
    return Text(
      message.content,
      style: TextStyle(
        color: isMe ? Colors.white : Colors.black87,
        fontSize: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Màu sắc từ ảnh
    final aMessageFromOther = const Color(0xFFF0F0F0);
    final aMessageFromMe = const Color(0xFF00C89C); // Màu app của bạn

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Hiển thị Avatar cho người khác
          if (!isMe)
            CircleAvatar(
              backgroundImage: (avatarUrl.isNotEmpty)
                  ? NetworkImage(avatarUrl)
                  : const AssetImage('assets/icon/default_avatar.png') as ImageProvider,
              radius: 16,
            ),
          if (!isMe) const SizedBox(width: 8),

          // Bong bóng tin nhắn
          Container(
            // Xóa padding cứng nếu là ảnh
            padding: message.messageType == 'image'
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? aMessageFromMe : aMessageFromOther,
              borderRadius: BorderRadius.circular(20),
            ),
            child: _buildContent(), // Gọi hàm build nội dung
          ),

          // Icon trạng thái (nếu là tôi gửi)
          if(isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: _buildStatusIcon(message.status),
            )
        ],
      ),
    );
  }

  /// Hiển thị icon cho trạng thái Gửi / Đã đọc
  Widget _buildStatusIcon(MessageStatus status) {
    IconData iconData;
    Color color = Colors.grey.shade400;
    double size = 16.0;

    switch (status) {
      case MessageStatus.pending:
        iconData = Icons.access_time;
        break;
      case MessageStatus.sent:
        iconData = Icons.done;
        break;
      case MessageStatus.delivered:
        iconData = Icons.done_all;
        break;
      case MessageStatus.read:
        iconData = Icons.done_all;
        color = Colors.blue; // Màu đã đọc
        break;
      case MessageStatus.failed:
        iconData = Icons.error_outline;
        color = Colors.red;
        break;
    }
    return Icon(iconData, color: color, size: size);
  }
}