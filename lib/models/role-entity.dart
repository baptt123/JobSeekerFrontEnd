class RoleEntity {
  final int roleId;
  final String roleName;

  RoleEntity({
    required this.roleId,
    required this.roleName,
  });

  factory RoleEntity.fromJson(Map<String, dynamic> json) => RoleEntity(
    roleId: json['role_id'],
    roleName: json['role_name'],
  );

  Map<String, dynamic> toJson() => {
    'role_id': roleId,
    'role_name': roleName,
  };
}
