class ChangePasswordDto {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordDto({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  /// Chuyển đổi object thành một Map để gửi đi dưới dạng JSON.
  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}