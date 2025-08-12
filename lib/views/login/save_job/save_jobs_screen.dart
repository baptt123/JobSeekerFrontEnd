import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/save_jobs_view_model.dart';
import '../../../widgets/login/savejob/bottom_nav.dart';
import '../../../widgets/login/savejob/job_card.dart';
import '../../../widgets/login/savejob/job_option_sheet.dart';


class SavedJobsScreen extends StatelessWidget {
  const SavedJobsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final savedJobsVM = Provider.of<SavedJobsViewModel>(context);
    final jobs = savedJobsVM.jobs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text('Save Job', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w700, fontSize: 22)),
        actions: [
          if (jobs.isNotEmpty)
            TextButton(
              child: Text('Delete all', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
              onPressed: () => savedJobsVM.deleteAll(),
            ),
        ],
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: jobs.length,
        padding: EdgeInsets.only(top: 4, bottom: 22),
        itemBuilder: (ctx, idx) {
          return JobCard(
            job: jobs[idx],
            onOptionsTap: () {
              savedJobsVM.selectJob(idx);
              showModalBottomSheet(
                context: ctx,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => JobOptionsSheet(
                  onSendMessage: () {},
                  onShare: () {},
                  onDelete: () {
                    savedJobsVM.deleteJob(idx);
                    Navigator.pop(ctx);
                  },
                  onApply: () {
                    Navigator.pop(ctx);
                  },
                ),
              ).then((_) => savedJobsVM.clearSelected());
            },
          );
        },
      ),
      bottomNavigationBar: BottomNav(selectedIndex: 4, onTap: (_) {}),
    );
  }
}
