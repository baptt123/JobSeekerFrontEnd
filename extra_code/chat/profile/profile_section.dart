import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  final String title;
  final List<String> items; // ✅ Sửa từ List sang List<String>

  const ProfileSection({required this.title, required this.items, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      children: items.map((item) => ListTile(title: Text(item))).toList(),
    );
  }
}
