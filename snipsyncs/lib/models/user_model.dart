class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role; // 'customer', 'staff', 'admin'
  final String? phone;
  final String? avatarUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.avatarUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'],
      role: json['role'] ?? 'customer',
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'phone': phone,
      'avatar_url': avatarUrl,
      'is_active': isActive,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? role,
    String? phone,
    String? avatarUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}