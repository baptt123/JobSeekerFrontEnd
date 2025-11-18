// view_models/profile_view_model.dart
import '../../dto/update_user_dto.dart';
import '../../models/user-entity.dart';
import '../../services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

// Trạng thái của view
enum ProfileState { idle, loading, success, error }

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();

  // Đã thay đổi User? -> UserEntity?
  UserEntity? _user;
  UserEntity? get user => _user;

  ProfileState _state = ProfileState.idle;
  ProfileState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // File ảnh đã chọn (từ gallery/camera)
  XFile? _pickedAvatar;
  XFile? get pickedAvatar => _pickedAvatar;

  // Hàm khởi tạo, tự động fetch data
  ProfileViewModel() {
    fetchUserProfile();
  }

  void _setState(ProfileState newState) {
    _state = newState;
    notifyListeners();
  }

  // 1. Lấy thông tin profile
  Future<void> fetchUserProfile() async {
    _setState(ProfileState.loading);
    try {
      _user = await _userService.getUserProfile();
      _setState(ProfileState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ProfileState.error);
    }
  }

  // 2. Chọn ảnh avatar
  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _pickedAvatar = image;
        notifyListeners(); // Cập nhật UI để hiển thị ảnh mới chọn
      }
    } catch (e) {
      _errorMessage = "Không thể chọn ảnh: $e";
      _setState(ProfileState.error); // Có thể dùng state riêng cho lỗi chọn ảnh
    }
  }

  // 3. Cập nhật profile
  Future<bool> updateUserProfile(UpdateUserDto dto) async {
    _setState(ProfileState.loading);
    try {
      // Gọi service với DTO và file ảnh đã chọn
      _user = await _userService.updateUser(dto, _pickedAvatar);
      _pickedAvatar = null; // Xóa file đã chọn sau khi update thành công
      _setState(ProfileState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ProfileState.error);
      return false;
    }
  }
}