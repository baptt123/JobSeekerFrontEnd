import 'package:dio/dio.dart';
import '../models/comments-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class CommentService {
  final Dio _dio = DioClient.getDio();

  // Lấy danh sách comment
  Future<List<CommentEntity>> getComments(int jobId) async {
    // Không try-catch ở đây để lỗi văng ra ViewModel xử lý
    final response = await _dio.get('/comments/job/$jobId');

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((e) => CommentEntity.fromJson(e))
          .toList();
    }
    return [];
  }

  // Gửi comment
  // Trả về void nếu thành công, ném lỗi nếu thất bại
  Future<void> postComment(int jobId, String content) async {
    await _dio.post(
      '/comments',
      data: {
        'jobId': jobId,
        'content': content,
      },
    );
  }
}