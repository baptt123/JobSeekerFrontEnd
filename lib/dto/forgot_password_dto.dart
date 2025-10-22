// dtos/forgot_password_dto.dart

class ForgotPasswordDto {
  final String email;

  ForgotPasswordDto({required this.email});

  /// Chuyển đổi đối tượng DTO thành một Map (JSON) để gửi đi trong body của request.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}