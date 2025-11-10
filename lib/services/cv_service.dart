import 'dart:typed_data'; // Vẫn cần cho Uint8List
import 'package:dio/dio.dart';
import 'package:job_seeker_frontend/utils/constant_api.dart'; // Giả định ConstantAPI.baseUrl là 'http://.../api'

import '../dto/create_cv_dto.dart';

class CvGenerationService {
  // Instance Dio dùng chung cho cả class
  final Dio _dio;

  CvGenerationService()
      : _dio = Dio(
    BaseOptions(
      // 1. baseUrl của bạn đã là .../cv
      baseUrl: '${ConstantAPI.baseUrl}/cv',
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Gọi API backend để tạo CV từ một prompt.
  /// Trả về dữ liệu PDF thô (raw) dưới dạng Uint8List.
  Future<Uint8List> generateCv(String prompt) async {
    try {
      final body = {'prompt': prompt};
      print('[CvService] Đang gửi prompt (dùng Dio)...');

      final response = await _dio.post(
        '/gen-cv', // 2. Đường dẫn sẽ là .../cv/gen-cv
        data: body,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        print('[CvService] Nhận được ${response.data.length} bytes PDF.');
        return response.data as Uint8List;
      } else {
        throw Exception('Server trả về 200 nhưng không có dữ liệu.');
      }
    } on DioException catch (e) {
      // 3. Xử lý lỗi Dio (rất tốt)
      print('[CvService] Lỗi Dio (generateCv): $e');
      if (e.response != null && e.response?.data != null) {
        // ... (Giữ nguyên logic xử lý lỗi phức tạp của bạn)
        // (Bỏ qua để cho ngắn gọn, nhưng logic của bạn ở đây là đúng)
      }
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception('Quá thời gian kết nối, vui lòng thử lại.');
        case DioExceptionType.connectionError:
          throw Exception('Không thể kết nối. Vui lòng kiểm tra mạng.');
        default:
          throw Exception('Lỗi không xác định: ${e.message}');
      }
    } catch (e) {
      print('[CvService] Lỗi không mong muốn (generateCv): $e');
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  /*
  ================================================================
  ✅ ĐIỀU CHỈNH 2 HÀM BÊN DƯỚI
  ================================================================
  */

  /// Hàm này gọi API preview và trả về HTML dưới dạng String
  /// (Đã điều chỉnh để dùng _dio của class)
  Future<String> previewCv(String templateId, CreateCvDto cvData) async {
    // 1. Không cần 'apiUat', vì ta dùng baseUrl
    // 2. Không tạo 'new Dio()'

    // Đường dẫn tương đối -> sẽ nối với baseUrl thành: .../cv/preview/templateId
    final path = '/preview/$templateId';

    try {
      final response = await _dio.post(
        path, // Dùng đường dẫn tương đối
        data: cvData.toJson(),
        options: Options(
          responseType: ResponseType.plain, // Yêu cầu trả về text (HTML)
        ),
      );

      // _dio tự động ném lỗi nếu status không phải 2xx
      return response.data; // response.data lúc này là String

    } on DioException catch (e) {
      // Tái sử dụng logic bắt lỗi tương tự như generateCv
      print('[CvService] Lỗi Dio (previewCv): $e');

      // Xử lý lỗi server 4xx/5xx
      if (e.response != null) {
        // Vì responseType là 'plain', e.response.data có thể là HTML/text lỗi
        print('Lỗi ${e.response?.statusCode}: ${e.response?.data}');
        throw Exception(
          'Không thể tải bản xem trước: ${e.response?.statusMessage}',
        );
      }

      // Lỗi mạng, timeout, etc.
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception('Quá thời gian, vui lòng thử lại.');
        case DioExceptionType.connectionError:
          throw Exception('Không thể kết nối. Vui lòng kiểm tra mạng.');
        default:
          throw Exception('Lỗi xem trước: ${e.message}');
      }
    } catch (e) {
      print('[CvService] Lỗi không mong muốn (previewCv): $e');
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  /// Hàm này gọi API download và trả về nguyên bản Response của Dio
  /// (Đã điều chỉnh để dùng _dio của class)
  Future<Response> downloadCv(String templateId, CreateCvDto cvData) async {
    // Đường dẫn tương đối -> .../cv/download/templateId
    final path = '/download/$templateId';

    try {
      final response = await _dio.post(
        path,
        data: cvData.toJson(),
        options: Options(
          responseType: ResponseType.bytes, // Sẵn sàng cho PDF/File

          // Giữ nguyên logic quan trọng của bạn:
          // Chấp nhận MỌI status code và không ném lỗi HTTP
          validateStatus: (status) {
            return status != null;
          },
        ),
      );

      // Trả về nguyên bản response (của Dio) để bên ngoài tự xử lý
      return response;

    } on DioException catch (e) {
      // 3. Vì 'validateStatus' đã chấp nhận mọi status,
      //    lỗi ở đây GẦN NHƯ CHỈ LÀ lỗi mạng (timeout, không kết nối...)
      print('[CvService] Lỗi Dio (downloadCv): $e');

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception('Quá thời gian, vui lòng thử lại.');
        case DioExceptionType.connectionError:
          throw Exception('Không thể kết nối. Vui lòng kiểm tra mạng.');
        default:
        // Vẫn ném lỗi chung phòng trường hợp khác
          throw Exception('Lỗi tải về: ${e.message}');
      }
    } catch (e) {
      print('[CvService] Lỗi không mong muốn (downloadCv): $e');
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }
}