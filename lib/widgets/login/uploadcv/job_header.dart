import 'package:flutter/material.dart';

class JobHeader extends StatelessWidget {
  const JobHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          child: FlutterLogo(size: 60), // Thay thành AssetImage nếu cần
        ),
        const SizedBox(height: 12),
        const Text(
          'UI/UX Designer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        const SizedBox(height: 8),
        const Text(
          'Google   •   California   •   1 day ago',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
