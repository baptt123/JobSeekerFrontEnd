// models/user-token-entity.dart

class UserToken {
  final String accessToken;
  final String refreshToken;
  final int userId;

  UserToken({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
  });

  // ✅ HÀM FromJson ĐÃ ĐƯỢC SỬA ĐỂ KHỚP VỚI RESPONSE CỦA BẠN
  factory UserToken.fromJson(Map<String, dynamic> json) {
    try {
      // 1. Kiểm tra 'user' có tồn tại không
      if (json['user'] == null || json['user'] is! Map<String, dynamic>) {
        throw Exception("Response JSON không chứa 'user' object.");
      }

      final userMap = json['user'] as Map<String, dynamic>;

      // 2. Kiểm tra 'id' có tồn tại và là int không
      if (userMap['id'] == null || userMap['id'] is! int) {
        throw Exception("Response JSON 'user' object không chứa 'id'.");
      }

      // 3. Lấy ID từ (json['user']['id'])
      final int idFromUser = userMap['id'];

      // 4. Lấy tokens
      final String accessToken = json['accessToken'] ?? '';
      final String refreshToken = json['refreshToken'] ?? '';

      if (accessToken.isEmpty || refreshToken.isEmpty) {
        throw Exception("Response JSON không chứa tokens.");
      }

      return UserToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: idFromUser, // Gán ID đã lấy được
      );

    } catch (e) {
      // Ném ra lỗi rõ ràng để ViewModel bắt được
      print("LỖI PARSE UserToken.fromJson: $e");
      throw Exception('Dữ liệu đăng nhập trả về không hợp lệ.');
    }
  }
}