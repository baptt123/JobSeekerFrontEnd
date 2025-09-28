import 'package:flutter/material.dart';

class ApplicationListItem extends StatelessWidget {
  final Map<String, dynamic> application;
  final VoidCallback onTap;

  const ApplicationListItem({super.key, required this.application, required this.onTap});

  Color getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Interview':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(application['user']['avatarUrl'])),
        title: Text(application['job']['title']),
        subtitle: Text('Ứng viên: ${application['user']['fullName']}'),
        trailing: Chip(
          label: Text(application['status']),
          backgroundColor: getStatusColor(application['status']),
        ),
        onTap: onTap,
      ),
    );
  }
}
