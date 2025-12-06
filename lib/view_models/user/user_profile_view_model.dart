import 'package:flutter/foundation.dart';
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

  // Getter giúp UI check trạng thái gọn hơn
  bool get isLoading => _state == ProfileState.loading;
  bool get isUnauthorized => _state == ProfileState.unauthorized;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  XFile? _pickedAvatar;
  XFile? get pickedAvatar => _pickedAvatar;

  // Constructor gọi fetch ngay (tuy nhiên UI cũng có gọi lại trong initState)
  ProfileViewModel() {
    fetchUserProfile();
  }

  void _setState(ProfileState newState) {
    _state = newState;
    notifyListeners();
  }

  // 1. Lấy profile (Logic chính)
  Future<void> fetchUserProfile() async {
    _setState(ProfileState.loading);

    try {
      // Kiểm tra token dưới local storage
      final token = await _storage.read(key: 'accessToken');

      if (token == null) {
        _user = null; // Đảm bảo user null
        _setState(ProfileState.unauthorized);
        return;
      }

      // Có token thì gọi API
      _user = await _userService.getUserProfile();
      _setState(ProfileState.success);
    } catch (e) {
      if (e.toString().contains('401')) {
        // Token hết hạn hoặc không hợp lệ
        await _storage.delete(key: 'accessToken'); // Xóa token cũ đi
        _user = null;
        _setState(ProfileState.unauthorized);
      } else {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _setState(ProfileState.error);
      }
    }
  }

  // 2. Chọn ảnh từ thư viện
  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _pickedAvatar = image;
        notifyListeners(); // Cập nhật UI để hiện ảnh vừa chọn (preview)
      }
    } catch (e) {
      if (kDebugMode) print("Lỗi chọn ảnh: $e");
    }
  }

  // 3. Cập nhật Profile
  Future<bool> updateUserProfile(UpdateUserDto dto) async {
    _setState(ProfileState.loading);
    _errorMessage = '';
    try {
      final updatedUser = await _userService.updateUser(dto, _pickedAvatar);
      _user = updatedUser; // Cập nhật lại user mới nhất từ server
      _pickedAvatar = null; // Reset ảnh đã chọn sau khi up thành công
      _setState(ProfileState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setState(ProfileState.error);
      return false;
    }
  }

  // 4. Đăng xuất
  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    // Xóa thêm các key khác nếu cần (refreshToken, fcmToken...)
    _user = null;
    _setState(ProfileState.unauthorized);
  }
}