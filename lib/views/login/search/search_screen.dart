// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/user/search_view_model.dart';
import '../../../widgets/login/search/filter_bar.dart';
import '../../../widgets/login/search/job_card.dart';
import '../../../widgets/login/search/search_header.dart';


class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: const [
              SearchHeader(),
              FilterBar(),
              Expanded(
                child: JobsList(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.add, color: Colors.white),
              ),
              label: '',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: ''),
          ],
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      ),
    );
  }
}

class JobsList extends StatelessWidget {
  const JobsList({super.key});

  @override
  Widget build(BuildContext context) {
    // Ở đây bạn có thể lấy danh sách công việc từ ViewModel hoặc tạm hardcode
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: const [
        JobCard(
          logo: Icons.work,
          colorLogo: Colors.blue,
          title: 'Flutter Developer',
          company: 'Google Inc',
          location: 'California, USA',
          tags: ['Flutter', 'Full-time', 'Senior'],
          salary: '20K',
        ),
        SizedBox(height: 16),
        JobCard(
          logo: Icons.code,
          colorLogo: Colors.pink,
          title: 'Backend Engineer',
          company: 'Facebook',
          location: 'New York, USA',
          tags: ['Node.js', 'Remote', 'Backend'],
          salary: '25K',
        ),
      ],
    );
  }
}
