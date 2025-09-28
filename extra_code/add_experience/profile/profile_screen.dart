import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../view_models/user/extra_view/profile_view_model.dart';
import '../../../../../widgets/login/extra_widget/chat/profile/profile_section.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProfileViewModel>(context); // ✅ Gõ kiểu cho vm

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(vm.location),
                  Text("${vm.followers} Followers, ${vm.following} Following"),
                  ElevatedButton(
                      onPressed: vm.editProfile,
                      child: Text('Edit profile')
                  ),
                  ...vm.sections.map(
                        (section) => ProfileSection(
                      title: section['title'] ?? '',
                      items: List<String>.from(section['items'] ?? []), // ✅ Quan trọng
                    ),
                  ).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
