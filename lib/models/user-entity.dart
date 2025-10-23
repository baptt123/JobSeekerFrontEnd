class UserEntity {
  final int userId;
  final String email;
  final String fullName;
  final String? phone;
  final String? city;
  final String? avatarUrl;
  final int? roleId;
  final int? companyId;
  final DateTime? createdAt;

  UserEntity({
    required this.userId,
    required this.email,
    required this.fullName,
    this.phone,
    this.city,
    this.avatarUrl,
    this.roleId,
    this.companyId,
    this.createdAt,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      userId: json['user_id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      city: json['city'],
      avatarUrl: json['avatar_url'],
      roleId: json['role_id'],
      companyId: json['company_id'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'email': email,
    'full_name': fullName,
    'phone': phone,
    'city': city,
    'avatar_url': avatarUrl,
    'role_id': roleId,
    'company_id': companyId,
    'created_at': createdAt?.toIso8601String(),
  };
}
