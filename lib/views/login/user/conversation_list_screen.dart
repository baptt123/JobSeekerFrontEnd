import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/conversation_list_view_model.dart';
import '../../../utils/app_colors.dart';
import 'message_screen.dart';

class ConversationListScreen extends StatelessWidget {
  const ConversationListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConversationListViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Messages"), centerTitle: true),
        body: Consumer<ConversationListViewModel>(
          builder: (context, vm, _) {
            if (vm.state == ConversationState.loading) return const Center(child: CircularProgressIndicator());
            if (vm.state == ConversationState.unauthorized) return const Center(child: Text("Please login"));

            return ListView.separated(
              itemCount: vm.users.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
              itemBuilder: (ctx, i) {
                final user = vm.users[i];
                return ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl == null ? Text(user.fullName[0]) : null,
                  ),
                  title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Tap to chat", style: TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MessageScreen(otherUserId: user.id, otherUserName: user.fullName, otherUserAvatar: user.avatarUrl ?? ''))),
                );
              },
            );
          },
        ),
      ),
    );
  }
}