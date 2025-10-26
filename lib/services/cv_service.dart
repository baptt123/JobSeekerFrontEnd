import 'dart:typed_data'; // Vẫn cần cho Uint8List
import 'package:dio/dio.dart';
import 'package:job_seeker_frontend/utils/constant_api.dart'; // Import Dio

class CvGenerationService {
  // Khởi tạo một instance của Dio
  final Dio _dio;

  CvGenerationService()
    : _dio = Dio(
        BaseOptions(
          baseUrl:'${ConstantAPI.baseUrl}/cv',
          connectTimeout: const Duration(seconds: 120), // 120 giây timeout
          receiveTimeout: const Duration(seconds: 120),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  /// Gọi API backend để tạo CV từ một prompt.
  /// Trả về dữ liệu PDF thô (raw) dưới dạng Uint8List.
  Future<Uint8List> generateCv(String prompt) async {
    try {
      // 1. Chuẩn bị body
      final body = {'prompt': prompt};

      // 2. Gửi request
      print('[CvService] Đang gửi prompt (dùng Dio)...');
      final response = await _dio.post(
        '/gen-cv', // Đường dẫn tương đối vì đã có baseUrl
        data: body,
        options: Options(
          // QUAN TRỌNG: Yêu cầu Dio trả về dữ liệu dưới dạng bytes
          responseType: ResponseType.bytes,
        ),
      );

      // 3. Xử lý response
      // Với ResponseType.bytes, response.data chính là Uint8List
      if (response.statusCode == 200 && response.data != null) {
        print('[CvService] Nhận được ${response.data.length} bytes PDF.');
        return response.data as Uint8List;
      } else {
        // Trường hợp này ít khi xảy ra nếu status 200
        throw Exception('Server trả về 200 nhưng không có dữ liệu.');
      }
    } on DioException catch (e) {
      // 4. Xử lý lỗi (mạnh mẽ hơn http)
      print('[CvService] Lỗi Dio: $e');

      // Lỗi từ server (Backend trả về 4xx, 5xx)
      if (e.response != null && e.response?.data != null) {
        try {
          // Backend của bạn trả về JSON lỗi, nhưng vì ta yêu cầu 'bytes',
          // e.response.data có thể là bytes của JSON. Ta cần parse lại.
          // Tuy nhiên, Dio đủ thông minh, nếu server trả về 500 với
          // content-type là 'application/json', nó sẽ tự parse.
          // Nếu không, ta phải tự parse.

          // Thử giả định nó đã được parse
          final errorData = e.response?.data;

          if (errorData is Map) {
            final message =
                errorData['message'] ?? 'Lỗi không xác định từ server';
            throw Exception('Lỗi Server: $message');
          } else {
            // Nếu nó không phải Map (có thể là bytes), ta thử decode
            // (Phần này hơi phức tạp, thường thì e.response.data đã là Map)
            throw Exception(
              'Lỗi ${e.response?.statusCode}: ${e.response?.statusMessage}',
            );
          }
        } catch (parseError) {
          throw Exception(
            'Lỗi ${e.response?.statusCode}: Không thể đọc thông báo lỗi.',
          );
        }
      }

      // Các lỗi khác (timeout, không có mạng, v.v.)
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw Exception('Quá thời gian kết nối, vui lòng thử lại.');
        case DioExceptionType.connectionError:
          throw Exception('Không thể kết nối. Vui lòng kiểm tra mạng.');
        default:
          throw Exception('Lỗi không xác định: ${e.message}');
      }
    } catch (e) {
      // Các lỗi chung khác
      print('[CvService] Lỗi không mong muốn: $e');
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }
}
