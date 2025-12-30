class Member {
  final int id;
  final int roleId;
  final String role;
  final String name;
  final String email;
  final String phone;
  final String dob;
  final String aadharNo;
  final String guardianName;
  final String guardianPhone;
  final String? userPhoto;
  final String? verificationDocument;
  final int status;

  Member({
    required this.id,
    required this.roleId,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    required this.aadharNo,
    required this.guardianName,
    required this.guardianPhone,
    this.userPhoto,
    this.verificationDocument,
    required this.status,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] ?? 0,
      roleId: json['role_id'] ?? 0,
      role: json['role'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dob: json['dob'] ?? '',
      aadharNo: json['aadhar_no'] ?? '',
      guardianName: json['guardian_name'] ?? '',
      guardianPhone: json['guardian_phone'] ?? '',
      userPhoto: json['user_photo'],
      verificationDocument: json['verification_document'],
      status: json['status'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_id': roleId,
      'role': role,
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
      'aadhar_no': aadharNo,
      'guardian_name': guardianName,
      'guardian_phone': guardianPhone,
      'user_photo': userPhoto,
      'verification_document': verificationDocument,
      'status': status,
    };
  }

  bool get isActive => status == 1;
}
