// lib/view_models/user/user_profile_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Import để dùng BuildContext
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../dto/update_user_dto.dart';
import '../../models/user-entity.dart';
import '../../services/user_service.dart';

enum ProfileState { idle, loading, success, error, unauthorized }

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserEntity? _user;
  UserEntity? get user => _user;

  ProfileState _state = ProfileState.idle;
  ProfileState get state => _state;

  bool get isLoading => _state == ProfileState.loading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  XFile? _pickedAvatar;
  XFile? get pickedAvatar => _pickedAvatar;

  ProfileViewModel() {
    fetchUserProfile();
  }

  void _setState(ProfileState newState) {
    _state = newState;
    notifyListeners();
  }

  // 1. Lấy thông tin Profile
  Future<void> fetchUserProfile() async {
    _setState(ProfileState.loading);
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        _user = null;
        _setState(ProfileState.unauthorized);
        return;
      }
      _user = await _userService.getUserProfile();
      _setState(ProfileState.success);
    } catch (e) {
      if (e.toString().contains('401')) {
        await _storage.delete(key: 'accessToken');
        _user = null;
        _setState(ProfileState.unauthorized);
      } else {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _setState(ProfileState.error);
      }
    }
  }

  // 2. Chọn ảnh và Tự động Upload ngay khi chọn
  Future<void> pickImage(BuildContext context) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _pickedAvatar = image;
        notifyListeners();

        // Gọi API update ngay lập tức chỉ với Avatar
        await updateInfo(context, fullName: _user?.fullName, onlyAvatar: true);
      }
    } catch (e) {
      if (kDebugMode) print("Lỗi chọn ảnh: $e");
    }
  }

  // 3. Cập nhật thông tin (Dùng chung cho cả Text và Avatar)
  Future<void> updateInfo(BuildContext context, {
    String? fullName,
    String? phone,
    String? city,
    bool onlyAvatar = false,
  }) async {
    if (_user == null) return;

    _setState(ProfileState.loading);

    try {
      // Tạo DTO
      final dto = UpdateUserDto(
        fullName: fullName ?? _user!.fullName,
        phone: phone ?? _user!.phone,
        city: city ?? _user!.city,
        // Email thường không cho sửa trực tiếp ở đây để bảo mật
      );

      // Gọi API (truyền _pickedAvatar nếu có)
      final updatedUser = await _userService.updateUser(dto, _pickedAvatar);

      _user = updatedUser; // Cập nhật lại UI với data mới từ server
      _pickedAvatar = null; // Reset ảnh tạm

      _setState(ProfileState.success);

      if (context.mounted && !onlyAvatar) {
        Navigator.pop(context); // Đóng popup edit
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật thành công!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setState(ProfileState.error);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $_errorMessage"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // // 4. Đăng xuất
  // Future<void> logout(BuildContext context) async {
  //   await _storage.deleteAll();
  //   _user = null;
  //   _setState(ProfileState.unauthorized);
  //   if(context.mounted) {
  //     Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  //   }
  // }
}