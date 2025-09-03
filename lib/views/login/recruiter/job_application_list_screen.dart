import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/recruiter/job_application_view_model.dart';
import '../../../widgets/login/recruiter/application_list_item.dart';
import 'application_detail_screen.dart';

class JobApplicationListScreen extends StatelessWidget {
  const JobApplicationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JobApplicationProvider>(context);
    final applications = provider.applications;

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách ứng tuyển')),
      body: ListView.builder(
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final app = applications[index];
          return ApplicationListItem(
            application: app,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ApplicationDetailScreen(applicationId: app['id']),
              ),
            ),
          );
        },
      ),
    );
  }
}
