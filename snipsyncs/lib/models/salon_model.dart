class SalonModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String? email;
  final String? image;
  final double rating;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SalonModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    this.image,
    this.rating = 0.0,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory SalonModel.fromJson(Map<String, dynamic> json) {
    return SalonModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'] ?? '',
      email: json['email'],
      image: json['image'],
      rating: (json['rating'] ?? 0).toDouble(),
      description: json['description'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'image': image,
      'rating': rating,
      'description': description,
      'is_active': isActive,
    };
  }
}