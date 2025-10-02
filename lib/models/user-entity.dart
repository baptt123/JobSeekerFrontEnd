class UserEntity {
  final int userId;
  final String email;
  final String fullName;
  final String? phone;
  final String? city;
  final String? avatarUrl;
  final int roleId;
  final int? companyId;
  final DateTime createdAt;

  UserEntity({
    required this.userId,
    required this.email,
    required this.fullName,
    this.phone,
    this.city,
    this.avatarUrl,
    required this.roleId,
    this.companyId,
    required this.createdAt,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
    userId: json['user_id'],
    email: json['email'],
    fullName: json['full_name'],
    phone: json['phone'],
    city: json['city'],
    avatarUrl: json['avatar_url'],
    roleId: json['role_id'],
    companyId: json['company_id'],
    createdAt: DateTime.parse(json['created_at']),
  );
}
