// lib/view_models/user/user_profile_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ✅ Import Storage
import 'package:image_picker/image_picker.dart';
import '../../dto/update_user_dto.dart';
import '../../models/user-entity.dart';
import '../../services/user_service.dart';

// ✅ Thêm trạng thái 'unauthorized'
enum ProfileState { idle, loading, success, error, unauthorized }

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(); // ✅ Khai báo Storage

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

  // 1. Lấy profile (CÓ KIỂM TRA ĐĂNG NHẬP)
  Future<void> fetchUserProfile() async {
    _setState(ProfileState.loading);

    try {
      // ✅ Kiểm tra token trước
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        _setState(ProfileState.unauthorized);
        return;
      }

      // Nếu có token mới gọi API
      _user = await _userService.getUserProfile();
      _setState(ProfileState.success);
    } catch (e) {
      // Nếu lỗi 401 từ server trả về cũng coi là unauthorized
      if (e.toString().contains('401')) {
        _setState(ProfileState.unauthorized);
      } else {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _setState(ProfileState.error);
      }
    }
  }

  // ... (Giữ nguyên các hàm pickImage, updateUserProfile) ...
  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _pickedAvatar = image;
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi chọn ảnh: $e");
    }
  }

  Future<bool> updateUserProfile(UpdateUserDto dto) async {
    _setState(ProfileState.loading);
    _errorMessage = '';
    try {
      final updatedUser = await _userService.updateUser(dto, _pickedAvatar);
      _user = updatedUser;
      _pickedAvatar = null;
      _setState(ProfileState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setState(ProfileState.error);
      return false;
    }
  }
}