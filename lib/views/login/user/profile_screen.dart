import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/user/user_profile_view_model.dart';
import '../../../models/user-entity.dart';

const Color kPrimaryColor = Color(0xFF6C63FF);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ... (Giữ nguyên các hàm _showEditProfileBottomSheet, _buildTextField)
  void _showEditProfileBottomSheet(BuildContext context, UserEntity user, ProfileViewModel vm) {
    // ... (Giữ nguyên logic cũ của bạn)
    final nameController = TextEditingController(text: user.fullName);
    final phoneController = TextEditingController(text: user.phone ?? '');
    final cityController = TextEditingController(text: user.city ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Chỉnh sửa thông tin", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildTextField(nameController, "Họ và tên", Icons.person),
              const SizedBox(height: 12),
              _buildTextField(phoneController, "Số điện thoại", Icons.phone, inputType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(cityController, "Thành phố / Tỉnh", Icons.location_city),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    vm.updateInfo(context, fullName: nameController.text.trim(), phone: phoneController.text.trim(), city: cityController.text.trim());
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return TextField(controller: controller, keyboardType: inputType, decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.grey), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          final user = vm.user;

          // 1. Loading
          if (vm.state == ProfileState.loading && user == null) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          // 2. [CẬP NHẬT] Xử lý Lỗi
          if (vm.state == ProfileState.error && user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(vm.errorMessage, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.fetchUserProfile(),
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: Colors.white),
                    child: const Text("Thử lại"),
                  )
                ],
              ),
            );
          }

          // 3. Unauthorized
          if (user == null || vm.state == ProfileState.unauthorized) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Vui lòng đăng nhập để xem hồ sơ"),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text("Đăng nhập ngay"),
                  )
                ],
              ),
            );
          }

          // 4. UI Profile (Giữ nguyên)
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
                      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kPrimaryColor.withOpacity(0.2), width: 2)),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                                  child: user.avatarUrl == null ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                                ),
                              ),
                              Positioned(bottom: 0, right: 0, child: CircleAvatar(radius: 16, backgroundColor: kPrimaryColor, child: IconButton(icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white), onPressed: () => vm.pickImage(context))))
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Flexible(child: Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 8),
                            InkWell(onTap: () => _showEditProfileBottomSheet(context, user, vm), child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.edit, size: 20, color: kPrimaryColor)))
                          ]),
                          const SizedBox(height: 4),
                          Text(user.email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          if(user.phone != null) Text(user.phone!, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Menu Sections (Giữ nguyên)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildMenuSection("Tài khoản", [
                            _buildMenuItem(Icons.person_outline, "Chỉnh sửa thông tin", () => _showEditProfileBottomSheet(context, user, vm)),
                            _buildMenuItem(Icons.description_outlined, "Quản lý CV", () => Navigator.pushNamed(context, '/manage_cv')),
                            _buildMenuItem(Icons.bookmark_border, "Công việc đã lưu", () => Navigator.pushNamed(context, '/save_job')),
                          ]),
                          const SizedBox(height: 20),
                          _buildMenuSection("Cài đặt", [
                            _buildMenuItem(Icons.settings_outlined, "Cài đặt chung", () => Navigator.pushNamed(context, '/settings')),
                            _buildMenuItem(Icons.help_outline, "Trợ giúp & Hỗ trợ", () {}),
                            _buildMenuItem(Icons.logout, "Đăng xuất", () => vm.logout(context), isDestructive: true),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              if (vm.isLoading && user != null) Container(color: Colors.black.withOpacity(0.3), child: const Center(child: CircularProgressIndicator(color: Colors.white))),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 8, bottom: 10), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54))),
      Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]), child: Column(children: items)),
    ]);
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: isDestructive ? Colors.red.withOpacity(0.1) : kPrimaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: isDestructive ? Colors.red : kPrimaryColor, size: 20)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDestructive ? Colors.red : Colors.black87)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}