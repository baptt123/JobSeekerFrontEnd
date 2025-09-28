import 'package:flutter/material.dart';

class JobInfoWidget extends StatelessWidget {
  final Map<String, dynamic> job;
  const JobInfoWidget({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(job['title']),
      subtitle: Text(job['description']),
    );
  }
}
