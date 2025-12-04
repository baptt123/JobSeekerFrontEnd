import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class ImageUploadService {
  final Dio _dio = DioClient.getDio(baseUrl: ConstantAPI.baseUrl);

  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({"file": await MultipartFile.fromFile(imageFile.path, filename: fileName)});
      final response = await _dio.post('/cloudinary-custom/upload-file', data: formData);
      return response.data['url'] as String?;
    } catch (e) { return null; }
  }
}