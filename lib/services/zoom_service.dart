import 'package:dio/dio.dart';

import '../dto/zoom_meeting_dto.dart';

class ZoomService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://192.168.67.109:3000')); // 🔧 đổi IP theo backend của bạn

  Future<ZoomMeetingDto> createMeeting(String topic) async {
    try {
      final response = await _dio.post(
        '/zoom/create-meeting',
        data: {'topic': topic},
      );

      return ZoomMeetingDto.fromJson(response.data);
    } catch (e) {
      print('❌ Zoom createMeeting error: $e');
      rethrow;
    }
  }
}
