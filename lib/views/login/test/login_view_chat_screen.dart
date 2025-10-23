import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/login_chat_view_model.dart';
import 'chat_view_screen.dart';

class LoginChatViewScreen extends StatefulWidget {
  const LoginChatViewScreen({super.key});

  @override
  State<LoginChatViewScreen> createState() => _LoginChatViewState();
}

class _LoginChatViewState extends State<LoginChatViewScreen> {
  final TextEditingController _currentNameCtrl = TextEditingController();
  final TextEditingController _peerNameCtrl = TextEditingController();

  Future<void> _startChat(BuildContext context) async {
    final vm = context.read<LoginChatViewModel>();

    final selfName = _currentNameCtrl.text.trim();
    final peerName = _peerNameCtrl.text.trim();

    if (selfName.isEmpty || peerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ 2 tên')),
      );
      return;
    }

    setState(() => vm.setLoading(true));

    try {
      // login current user
      final currentUser = await vm.login(selfName);

      // login peer user (người muốn chat cùng)
      final peerUser = await vm.login(peerName);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatViewScreen(
              currentUser: currentUser,
              peerId: peerUser.userId,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi: $e')),
      );
    } finally {
      setState(() => vm.setLoading(false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginChatViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập & Chọn người để chat")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _currentNameCtrl,
              decoration: const InputDecoration(
                labelText: "Tên của bạn (full_name)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _peerNameCtrl,
              decoration: const InputDecoration(
                labelText: "Tên người bạn muốn chat (full_name)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: vm.isLoading ? null : () => _startChat(context),
              icon: const Icon(Icons.chat_bubble_outline),
              label: vm.isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text("Bắt đầu chat"),
            ),
          ],
        ),
      ),
    );
  }
}
