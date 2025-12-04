import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../dto/update_user_dto.dart';
import '../models/user-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class UserService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/user');

  Future<UserEntity> getUserProfile() async {
    try {
      final response = await _dio.get('/profile');
      return UserEntity.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<UserEntity> updateUser(UpdateUserDto dto, XFile? avatarFile) async {
    try {
      final Map<String, dynamic> formDataMap = dto.toJson();
      if (avatarFile != null) {
        String fileName = avatarFile.path.split('/').last;
        formDataMap['avatar'] = await MultipartFile.fromFile(avatarFile.path, filename: fileName);
      }

      final response = await _dio.put(
        '/update-user',
        data: FormData.fromMap(formDataMap),
      );

      return UserEntity.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}