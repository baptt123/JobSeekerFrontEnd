// lib/views/login/user/profile_screen.dart

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../dto/update_user_dto.dart';
import '../../../models/user-entity.dart';
import '../../../view_models/user/user_profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ProfileViewModel>();
    // Gọi fetch mỗi khi vào màn hình để check lại trạng thái login/logout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchUserProfile();
    });
    viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    final user = context.read<ProfileViewModel>().user;
    if (user != null) _updateControllers(user);
  }

  void _updateControllers(UserEntity? user) {
    if (user != null) {
      if (_fullNameController.text != user.fullName) _fullNameController.text = user.fullName;
      if (_emailController.text != user.email) _emailController.text = user.email;
      if (_phoneController.text != (user.phone ?? '')) _phoneController.text = user.phone ?? '';
      if (_cityController.text != (user.city ?? '')) _cityController.text = user.city ?? '';
    }
  }

  @override
  void dispose() {
    context.read<ProfileViewModel>().removeListener(_onViewModelChanged);
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    final viewModel = context.read<ProfileViewModel>();
    final dto = UpdateUserDto(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      city: _cityController.text.isNotEmpty ? _cityController.text : null,
    );
    final success = await viewModel.updateUserProfile(dto);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Cập nhật thành công!' : 'Cập nhật thất bại: ${viewModel.errorMessage}'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ Sơ Của Tôi')),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {

          // 1. Loading
          if (viewModel.state == ProfileState.loading && viewModel.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. ✅ Chưa đăng nhập (Unauthorized)
          if (viewModel.state == ProfileState.unauthorized) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text("Vui lòng đăng nhập để xem hồ sơ", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Chuyển sang màn hình Login
                      Navigator.pushNamed(context, '/login').then((_) {
                        // Khi quay lại, reload data
                        viewModel.fetchUserProfile();
                      });
                    },
                    icon: const Icon(Icons.login),
                    label: const Text("Đăng nhập ngay"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                    ),
                  )
                ],
              ),
            );
          }

          // 3. Lỗi
          if (viewModel.state == ProfileState.error && viewModel.user == null) {
            return Center(
              child: Text('Lỗi: ${viewModel.errorMessage}', textAlign: TextAlign.center),
            );
          }

          // 4. Hiển thị Form (Khi đã có user)
          if (viewModel.user == null) return const SizedBox.shrink();

          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildAvatar(viewModel),
                    const SizedBox(height: 24),
                    _buildTextField(controller: _fullNameController, label: 'Họ và tên', icon: Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress, readOnly: true), // Thường email không cho sửa
                    const SizedBox(height: 16),
                    _buildTextField(controller: _phoneController, label: 'Số điện thoại', icon: Icons.phone, keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    _buildTextField(controller: _cityController, label: 'Thành phố', icon: Icons.location_city),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: viewModel.state == ProfileState.loading ? null : _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(viewModel.state == ProfileState.loading ? 'Đang cập nhật...' : 'Lưu Thay Đổi'),
                    ),
                  ],
                ),
              ),
              if (viewModel.state == ProfileState.loading)
                Container(color: Colors.black12, child: const Center(child: CircularProgressIndicator())),
            ],
          );
        },
      ),
    );
  }

  // (Giữ nguyên các widget con _buildAvatar, _buildTextField của bạn)
  Widget _buildAvatar(ProfileViewModel viewModel) {
    final pickedImage = viewModel.pickedAvatar;
    final networkImageUrl = viewModel.user?.avatarUrl;
    ImageProvider? imageProvider;

    if (pickedImage != null) {
      imageProvider = FileImage(File(pickedImage.path));
    } else if (networkImageUrl != null && networkImageUrl.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(networkImageUrl);
    } else {
      imageProvider = null;
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: imageProvider,
            child: (imageProvider == null) ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
          ),
          Positioned(
            bottom: 0, right: 0,
            child: Material(
              color: Colors.blue, borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => viewModel.pickImage(),
                child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.edit, color: Colors.white, size: 20)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType keyboardType = TextInputType.text, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.white,
      ),
      validator: (val) => (val == null || val.isEmpty) ? '$label không được để trống' : null,
    );
  }
}