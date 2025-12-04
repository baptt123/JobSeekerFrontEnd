// lib/view_models/user/user_profile_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../dto/update_user_dto.dart';
import '../../models/user-entity.dart';
import '../../services/user_service.dart';

enum ProfileState { idle, loading, success, error }

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();

  UserEntity? _user;
  UserEntity? get user => _user;

  ProfileState _state = ProfileState.idle;
  ProfileState get state => _state;

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

  // 1. Lấy profile
  Future<void> fetchUserProfile() async {
    _setState(ProfileState.loading);
    try {
      _user = await _userService.getUserProfile();
      _setState(ProfileState.success);
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setState(ProfileState.error);
    }
  }

  // 2. Chọn ảnh từ thư viện
  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _pickedAvatar = image;
        notifyListeners(); // Cập nhật UI để hiện ảnh preview
      }
    } catch (e) {
      print("Lỗi chọn ảnh: $e");
    }
  }

  // 3. Cập nhật Profile
  Future<bool> updateUserProfile(UpdateUserDto dto) async {
    _setState(ProfileState.loading);
    _errorMessage = '';

    try {
      // Gọi API cập nhật
      final updatedUser = await _userService.updateUser(dto, _pickedAvatar);

      // ✅ CẬP NHẬT THÀNH CÔNG: Gán user mới vào state
      _user = updatedUser;
      _pickedAvatar = null; // Xóa ảnh tạm sau khi upload xong

      _setState(ProfileState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setState(ProfileState.error);
      return false;
    }
  }
}