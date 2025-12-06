import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../dto/update_user_dto.dart';
import '../models/user-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class UserService {
  // Đảm bảo DioClient.getDio đã cấu hình Interceptor để gắn Token tự động
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/user');

  // Lấy thông tin Profile
  Future<UserEntity> getUserProfile() async {
    try {
      final response = await _dio.get('/profile');
      // Giả sử API trả về { "data": { ...user_info... } }
      return UserEntity.fromJson(response.data['data']);
    } on DioException catch (e) {
      // Ném lỗi ra để ViewModel bắt
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  // Cập nhật thông tin Profile (kèm ảnh avatar nếu có)
  Future<UserEntity> updateUser(UpdateUserDto dto, XFile? avatarFile) async {
    try {
      // Chuyển DTO sang Map
      final Map<String, dynamic> formDataMap = dto.toJson();

      // Nếu có file ảnh, thêm vào FormData
      if (avatarFile != null) {
        String fileName = avatarFile.path.split('/').last;
        formDataMap['avatar'] = await MultipartFile.fromFile(avatarFile.path, filename: fileName);
      }

      // Gọi API PUT
      final response = await _dio.put(
        '/update-user', // Kiểm tra lại endpoint backend của bạn
        data: FormData.fromMap(formDataMap),
      );

      return UserEntity.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}