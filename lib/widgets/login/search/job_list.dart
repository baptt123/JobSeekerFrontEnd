import 'package:flutter/material.dart';

class JobList extends StatelessWidget {
  final List<dynamic> jobs;

  const JobList({required this.jobs});

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Center(child: Text("No jobs found"));
    }

    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (context, i) {
        final job = jobs[i];
        return Card(
          child: ListTile(
            title: Text(job['title'] ?? "Untitled"),
            subtitle: Text(job['company_id'].toString()),
          ),
        );
      },
    );
  }
}
