// views/profile_screen.dart
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../dto/update_user_dto.dart';
import '../../../models/user-entity.dart';
import '../../../view_models/user/user_profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers cho các trường text
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Lắng nghe view model để cập nhật controller khi có dữ liệu
    // Dùng context.read vì đây là bên trong initState
    final viewModel = context.read<ProfileViewModel>();

    // Cập nhật controller ngay lập tức nếu data đã có sẵn
    if (viewModel.user != null) {
      _updateControllers(viewModel.user);
    }

    // Thêm listener để bắt các thay đổi trong tương lai (sau khi fetch)
    viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    // Cập nhật controller khi view model báo có thay đổi (vd: fetch xong)
    final user = context.read<ProfileViewModel>().user;
    if (user != null) {
      _updateControllers(user);
    }
  }

  void _updateControllers(UserEntity? user) {
    if (user != null) {
      // Chỉ gán nếu text khác nhau, tránh việc con trỏ nhảy lung tung
      if (_fullNameController.text != user.fullName) {
        _fullNameController.text = user.fullName;
      }
      if (_emailController.text != user.email) {
        _emailController.text = user.email;
      }
      if (_phoneController.text != (user.phone ?? '')) {
        _phoneController.text = user.phone ?? '';
      }
      if (_cityController.text != (user.city ?? '')) {
        _cityController.text = user.city ?? '';
      }
    }
  }

  @override
  void dispose() {
    // Gỡ listener khi widget bị hủy
    context.read<ProfileViewModel>().removeListener(_onViewModelChanged);

    // Hủy các controller
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    // Kiểm tra validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<ProfileViewModel>();

    // Tạo DTO từ controllers
    final dto = UpdateUserDto(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null, // Gửi null nếu rỗng
      city: _cityController.text.isNotEmpty ? _cityController.text : null, // Gửi null nếu rỗng
    );

    // Gọi hàm cập nhật từ view model
    final success = await viewModel.updateUserProfile(dto);

    // Hiển thị SnackBar sau khi cập nhật
    if (mounted) { // Kiểm tra xem widget còn trên cây không
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
      appBar: AppBar(
        title: const Text('Hồ Sơ Của Tôi'),
      ),
      // Sử dụng Consumer để lắng nghe thay đổi và rebuild
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {

          // Trạng thái loading ban đầu (chưa có data)
          if (viewModel.state == ProfileState.loading && viewModel.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Trạng thái lỗi ban đầu (chưa có data)
          if (viewModel.state == ProfileState.error && viewModel.user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Lỗi tải dữ liệu: ${viewModel.errorMessage}', textAlign: TextAlign.center),
              ),
            );
          }

          // Nếu user là null (trường hợp lạ, nhưng nên check)
          if (viewModel.user == null) {
            return const Center(child: Text('Không tìm thấy dữ liệu người dùng.'));
          }

          // Hiển thị form khi đã có dữ liệu
          return Stack(
            children: [
              // Form nội dung
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Widget hiển thị và chọn Avatar
                    _buildAvatar(viewModel),
                    const SizedBox(height: 24),

                    // Trường Họ và tên
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Họ và tên',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Họ và tên không được để trống';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Trường Email
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email không được để trống';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Trường Số điện thoại
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Số điện thoại',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Trường Thành phố
                    _buildTextField(
                      controller: _cityController,
                      label: 'Thành phố',
                      icon: Icons.location_city,
                    ),
                    const SizedBox(height: 32),

                    // Nút Lưu thay đổi
                    ElevatedButton(
                      // Vô hiệu hóa nút khi đang loading
                      onPressed: viewModel.state == ProfileState.loading ? null : _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.blue, // Thêm màu
                        foregroundColor: Colors.white, // Thêm màu chữ
                      ),
                      child: Text(viewModel.state == ProfileState.loading ? 'Đang cập nhật...' : 'Lưu Thay Đổi'),
                    ),
                  ],
                ),
              ),

              // Lớp phủ loading khi đang CẬP NHẬT (đã có data)
              if (viewModel.state == ProfileState.loading && viewModel.user != null)
                Container(
                  // Lớp phủ mờ
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Widget con cho Avatar
  Widget _buildAvatar(ProfileViewModel viewModel) {
    // Lấy ảnh đã chọn (nếu có)
    final pickedImage = viewModel.pickedAvatar;
    // Lấy ảnh từ user data (nếu có)
    final networkImageUrl = viewModel.user?.avatarUrl;

    // SỬA 1: Đổi kiểu của 'imageProvider' từ 'Widget' thành 'ImageProvider?'
    ImageProvider? imageProvider;

    if (pickedImage != null) {
      // 1. Ưu tiên hiển thị ảnh mới chọn (dạng File)
      // SỬA 2: Bỏ 'as Widget'
      imageProvider = FileImage(File(pickedImage.path));
    } else if (networkImageUrl != null && networkImageUrl.isNotEmpty) {
      // 2. Hiển thị ảnh từ server (dùng CachedNetworkImage)
      // SỬA 3: Bỏ 'as Widget'
      imageProvider = CachedNetworkImageProvider(networkImageUrl);
    } else {
      // 3. Không có ảnh, gán 'imageProvider' là null.
      // Việc này sẽ cho phép 'child' (Icon) của CircleAvatar được hiển thị.
      // SỬA 4: Thay vì gán AssetImage, hãy gán null.
      imageProvider = null;
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200], // Màu nền cho avatar
            // Hiển thị ảnh - Giờ đã đúng kiểu dữ liệu
            backgroundImage: imageProvider,
            // Xử lý lỗi cho ảnh mạng (CachedNetworkImageProvider tự xử lý)
            // Nếu dùng FileImage, cần thêm onError
            onBackgroundImageError: (pickedImage == null && networkImageUrl != null && networkImageUrl.isNotEmpty) ? (exception, stackTrace) {
              // Xử lý lỗi tải ảnh mạng
              print('Lỗi tải ảnh: $exception');
            } : null,

            // Icon dự phòng này sẽ tự động hiển thị khi 'backgroundImage' là null,
            // đúng như logic 'imageProvider = null' ở trên.
            child: (imageProvider == null) // Logic được đơn giản hóa
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          // Nút Edit avatar
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
              elevation: 2, // Thêm đổ bóng
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => viewModel.pickImage(), // Gọi hàm chọn ảnh
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget con cho các trường TextFormField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator, // Thêm validator
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]), // Màu icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!), // Màu viền
        ),
        enabledBorder: OutlineInputBorder( // Viền khi không focus
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder( // Viền khi focus
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white, // Màu nền
      ),
      validator: validator, // Gán validator
    );
  }
}