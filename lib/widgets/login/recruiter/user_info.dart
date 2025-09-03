import 'package:flutter/material.dart';

class UserInfoWidget extends StatelessWidget {
  final Map<String, dynamic> user;
  const UserInfoWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(user['avatarUrl'])),
      title: Text(user['fullName']),
      subtitle: Text(user['email']),
    );
  }
}
