import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../dto/create_cv_dto.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class CvGenerationService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/cv');

  Future<Uint8List> generateCv(String prompt) async {
    final response = await _dio.post('/gen-cv', data: {'prompt': prompt}, options: Options(responseType: ResponseType.bytes));
    return response.data as Uint8List;
  }

  Future<String> previewCv(String templateId, CreateCvDto cvData) async {
    final response = await _dio.post('/preview/$templateId', data: cvData.toJson(), options: Options(responseType: ResponseType.plain));
    return response.data;
  }

  Future<Response> downloadCv(String templateId, CreateCvDto cvData) async {
    return await _dio.post('/download/$templateId', data: cvData.toJson(), options: Options(responseType: ResponseType.bytes, validateStatus: (status) => status != null));
  }
}