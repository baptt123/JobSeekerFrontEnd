class ChangePasswordDTO {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordDTO({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }

  factory ChangePasswordDTO.fromJson(Map<String, dynamic> json) {
    return ChangePasswordDTO(
      oldPassword: json['oldPassword'] as String,
      newPassword: json['newPassword'] as String,
      confirmPassword: json['confirmPassword'] as String,
    );
  }
}
