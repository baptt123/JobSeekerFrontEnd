import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/recruiter/job_application_view_model.dart';
import '../../../widgets/login/recruiter/job_info.dart';
import '../../../widgets/login/recruiter/user_info.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final int applicationId;

  const ApplicationDetailScreen({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JobApplicationProvider>(context);
    final application = provider.applications.firstWhere(
      (app) => app['id'] == applicationId,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết ứng tuyển")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "CÔNG VIỆC",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            JobInfoWidget(job: application['job']),
            const Divider(),
            const Text(
              "ỨNG VIÊN",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            UserInfoWidget(user: application['user']),
            const Divider(),
            Text(
              "Thư xin việc: ${application['coverLetter']?.isNotEmpty == true ? application['coverLetter'] : "(không có)"}",
            ),
            const Spacer(),
            if (application['status'] != 'Accepted')
              ElevatedButton.icon(
                onPressed: () {
                  provider.acceptApplication(applicationId);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text("Duyệt ứng viên"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            if (application['status'] == 'Accepted')
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: const Chip(
                  label: Text("Đã duyệt"),
                  backgroundColor: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
