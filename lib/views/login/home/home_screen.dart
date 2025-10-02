// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../view_models/user/home_view_model.dart';
// import '../../../widgets/login/home/home_banner.dart';
// import '../../../widgets/login/home/home_job_card.dart';
// import '../../../widgets/login/home/home_stats_panel.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => HomeViewModel(),
//       child: Consumer<HomeViewModel>(
//         builder: (context, vm, _) {
//           return Scaffold(
//             body: ListView(
//               children: [
//                 const SizedBox(height: 30),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Text(
//                     'Hello\nOrlando Diggs.',
//                     style: Theme.of(context)
//                         .textTheme
//                         .headlineSmall
//                         ?.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const HomeBanner(),
//                 const SizedBox(height: 16),
//                 const HomeStatsPanel(),
//                 const SizedBox(height: 16),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Text(
//                     'Recent Job List',
//                     style: Theme.of(context)
//                         .textTheme
//                         .titleMedium
//                         ?.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 const HomeJobCard(),
//               ],
//             ),
//             bottomNavigationBar: BottomNavigationBar(
//               currentIndex: vm.selectedTab,
//               onTap: vm.setSelectedTab,
//               items: const [
//                 BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
//                 BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
//                 BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: ''),
//                 BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), label: ''),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


// views/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/job_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JobViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Các job đề xuất cho bạn")),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: vm.jobs.length,
        itemBuilder: (context, index) {
          final job = vm.jobs[index];
          return Card(
            child: ListTile(
              title: Text(job.title),
              subtitle: Text("${job.company?.name ?? ''} • ${job.location ?? ''}"),
              trailing: Text(job.jobType ?? ''),
            ),
          );
        },
      ),
    );
  }
}
