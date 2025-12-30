class Role {
  final int roleId;
  final String role;
  final int status;

  Role({required this.roleId, required this.role, required this.status});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: json['role_id'] ?? 0,
      role: json['role'] ?? '',
      status: json['status'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {'role_id': roleId, 'role': role, 'status': status};
  }

  bool get isActive => status == 1;
}
