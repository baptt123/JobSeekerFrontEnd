import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/user_profile_view_model.dart';
import '../../../utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ... (giữ nguyên logic controller) ...
  // Để ngắn gọn, mình tập trung vào phần Build

  @override
  Widget build(BuildContext context) {
    // Giả sử logic Controller giữ nguyên từ file cũ
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.pushNamed(context, '/settings'))],
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          final user = vm.user;
          if (user == null) return const Center(child: CircularProgressIndicator());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(radius: 50, backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null),
                      Positioned(bottom: 0, right: 0, child: CircleAvatar(backgroundColor: AppColors.primary, radius: 16, child: IconButton(icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white), onPressed: vm.pickImage)))
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildProfileField("Full Name", user.fullName, Icons.person),
                _buildProfileField("Email", user.email, Icons.email),
                _buildProfileField("Phone", user.phone ?? "Not set", Icons.phone),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () { /* Logic update */ },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 50)),
                  child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}