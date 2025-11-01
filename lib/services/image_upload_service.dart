// services/image_upload_service.dart (TẠO FILE MỚI)
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constant_api.dart';

class ImageUploadService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ConstantAPI.baseUrl));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ImageUploadService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await _storage.read(key: 'accessToken');
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
    ));
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        // 'file' là key bạn định nghĩa trong FileInterceptor
        "file": await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName
        ),
      });

      // Gọi API bạn đã tạo
      final response = await _dio.post(
        '/cloudinary-custom/upload-file',
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Trả về secure_url
        return response.data['url'] as String?;
      }
      return null;
    } on DioException catch (e) {
      print("Lỗi upload ảnh: ${e.response?.data}");
      return null;
    }
  }
}