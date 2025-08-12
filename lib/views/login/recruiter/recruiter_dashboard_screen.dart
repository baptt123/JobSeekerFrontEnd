import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/recruiter/recruiter_dashboard_view_model.dart';
import '../../../widgets/login/recruiter/recruiter_statistic_card.dart';


class RecruiterDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecruiterDashboardViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Recruiter Dashboard'),
        ),
        body: Consumer<RecruiterDashboardViewModel>(
          builder: (context, vm, _) => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RecruiterStatisticCard(
                    label: "My Jobs",
                    value: vm.myJobs,
                    icon: Icons.work_outline,
                  ),
                  RecruiterStatisticCard(
                    label: "Applicants",
                    value: vm.applicants,
                    icon: Icons.person_search,
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => vm.createJobPosting(),
                child: Text("Post New Job"),
              ),
              // ... Thêm: danh sách job, ứng viên, v.v.
            ],
          ),
        ),
      ),
    );
  }
}
