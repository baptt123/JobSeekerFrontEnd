// lib/views/login/user/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/user_profile_view_model.dart';

// Màu chủ đạo
const Color kPrimaryColor = Color(0xFF6C63FF);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();

    // Fetch data ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().fetchUserProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          Consumer<ProfileViewModel>(
            builder: (_, vm, __) {
              return vm.user != null
                  ? IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              )
                  : const SizedBox();
            },
          )
        ],
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          // 1. Loading
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          // 2. Chưa đăng nhập
          if (vm.isUnauthorized || vm.user == null) {
            return _buildGuestView(context);
          }

          // 3. Đã đăng nhập
          final user = vm.user!;
          _nameController.text = user.fullName;
          _phoneController.text = user.phone ?? "";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar Area
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kPrimaryColor, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: vm.pickedAvatar != null
                              ? null
                              : (user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null),
                          child: vm.pickedAvatar != null
                              ? ClipOval(child: Image.asset(vm.pickedAvatar!.path, fit: BoxFit.cover, width: 120, height: 120))
                              : (user.avatarUrl == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: CircleAvatar(
                          backgroundColor: kPrimaryColor,
                          radius: 20,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                            onPressed: vm.pickImage,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Form Fields
                _buildProfileField("Họ và tên", _nameController, Icons.person),
                _buildReadOnlyField("Email", user.email, Icons.email),
                _buildProfileField("Số điện thoại", _phoneController, Icons.phone),

                const SizedBox(height: 30),

                // Nút Lưu thay đổi
                ElevatedButton(
                  onPressed: () async {
                    // Logic update profile ở đây
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 16),

                // 🔥 [MỚI] Nút Quản lý CV
                OutlinedButton.icon(
                  onPressed: () {
                    // Chuyển hướng đến màn hình quản lý CV
                    Navigator.pushNamed(context, '/manage_cv');
                  },
                  icon: const Icon(Icons.description_outlined, color: kPrimaryColor),
                  label: const Text(
                    "Quản lý CV của tôi",
                    style: TextStyle(color: kPrimaryColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: kPrimaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 16),

                // Nút Đăng xuất
                OutlinedButton(
                  onPressed: () async {
                    await vm.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Đăng xuất", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.lock_person_outlined, size: 80, color: kPrimaryColor),
            ),
            const SizedBox(height: 24),
            const Text("Bạn chưa đăng nhập", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Vui lòng đăng nhập để xem và chỉnh sửa hồ sơ.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Đăng nhập ngay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: kPrimaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimaryColor, width: 2)),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}