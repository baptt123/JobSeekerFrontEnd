import 'package:dio/dio.dart';
import '../dto/zoom_meeting_dto.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class ZoomService {
  final Dio _dio = DioClient.getDio(baseUrl: ConstantAPI.baseUrl);

  Future<ZoomMeetingDto> createMeeting(String topic) async {
    try {
      final response = await _dio.post('/zoom/create-meeting', data: {'topic': topic});
      return ZoomMeetingDto.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi tạo Zoom');
    }
  }
}