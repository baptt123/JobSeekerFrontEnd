import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../lib/view_models/admin/admin_dashboard_view_model.dart';
import '../../lib/widgets/login/extra_widget/chat/admin/admin_statistic_card.dart';


class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminDashboardViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard'),
        ),
        body: Consumer<AdminDashboardViewModel>(
          builder: (context, vm, _) => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AdminStatisticCard(
                    label: "Total Users",
                    value: vm.totalUsers,
                    icon: Icons.people,
                  ),
                  AdminStatisticCard(
                    label: "Total Jobs",
                    value: vm.totalJobs,
                    icon: Icons.work,
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => vm.loadData(),
                child: Text("Reload Data"),
              ),
              // ... các widget khác như danh sách users, báo cáo ...
            ],
          ),
        ),
      ),
    );
  }
}
