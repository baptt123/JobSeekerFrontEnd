// dto/update_user_dto.dart
// DTO để gửi dữ liệu cập nhật. Chỉ chứa các trường có thể cập nhật.

class UpdateUserDto {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? city;
  // Không cần avatar_url ở đây vì nó sẽ được gửi dưới dạng file

  UpdateUserDto({
    this.fullName,
    this.email,
    this.phone,
    this.city,
  });

  // Method để convert DTO thành Map<String, dynamic>
  // Backend sẽ chỉ cập nhật các trường không null
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (fullName != null) data['full_name'] = fullName;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (city != null) data['city'] = city;
    return data;
  }
}