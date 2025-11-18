// services/user_service.dart
import 'package:image_picker/image_picker.dart';
import '../dto/update_user_dto.dart';
import 'package:dio/dio.dart';

import '../models/user-entity.dart';
import '../utils/constant_api.dart';

class UserService {
  // Thay thế bằng IP của máy bạn, 10.0.2.2 là địa chỉ localhost cho emulator Android
  final String _baseUrl = ConstantAPI.baseUrl + '/user';
  final Dio _dio = Dio();

  // 1. Lấy thông tin user profile
  // Đã thay đổi return type từ User -> UserEntity
  Future<UserEntity> getUserProfile() async {
    try {
      final response = await _dio.get('$_baseUrl/profile');
      if (response.statusCode == 200) {
        // Dữ liệu user nằm trong key 'data'
        // Đã thay đổi User.fromJson -> UserEntity.fromJson
        return UserEntity.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load user profile');
      }
    } on DioException catch (e) {
      // Xử lý lỗi Dio (network, timeout,...)
      throw Exception('Error fetching profile: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  // 2. Cập nhật thông tin user
  // Đã thay đổi return type từ User -> UserEntity
  Future<UserEntity> updateUser(UpdateUserDto dto, XFile? avatarFile) async {
    try {
      // Tạo FormData
      final formDataMap = dto.toJson();

      // Nếu có file avatar mới, thêm vào FormData
      if (avatarFile != null) {
        formDataMap['avatar'] = await MultipartFile.fromFile(
          avatarFile.path,
          filename: avatarFile.name,
        );
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _dio.put(
        '$_baseUrl/update-user',
        data: formData,
      );

      if (response.statusCode == 200) {
        // Dữ liệu user đã cập nhật nằm trong key 'data'
        // Đã thay đổi User.fromJson -> UserEntity.fromJson
        return UserEntity.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update user profile');
      }
    } on DioException catch (e) {
      throw Exception('Error updating profile: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }
}