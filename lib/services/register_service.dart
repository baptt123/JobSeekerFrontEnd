import 'package:dio/dio.dart';
import '../dto/register_dto.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class RegisterService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/auth');

  Future<Response> register(RegisterDTO registerData) async {
    try {
      // DioClient tự xử lý timeout và base url
      return await _dio.post('/register', data: registerData.toJson());
    } catch (e) {
      rethrow;
    }
  }
}