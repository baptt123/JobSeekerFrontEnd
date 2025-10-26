import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';
import 'package:job_seeker_frontend/widget/user/suggest_job_card.dart';

class JobsList extends StatelessWidget {
  final HomeViewModel vm;
  const JobsList({Key? key, required this.vm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: vm.jobs.length,
        itemBuilder: (context, index) {
          return SuggestedJobCard(job: vm.jobs[index]);
        },
      ),
    );
  }
}