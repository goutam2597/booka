class UserModel {
  final int id;
  final String name;
  final String? username;
  final String email;
  final String? image;
  final String? emailVerifiedAt;
  final String? status;
  final String? provider;
  final String? providerId;
  final String? createdAt;
  final String? updatedAt;
  final String? phone;
  final String? country;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? address;

  UserModel({
    required this.id,
    required this.name,
    this.username,
    required this.email,
    this.image,
    this.emailVerifiedAt,
    this.status,
    this.provider,
    this.providerId,
    this.createdAt,
    this.updatedAt,
    this.phone,
    this.country,
    this.city,
    this.state,
    this.zipCode,
    this.address,
  });

  /// Deserialize from JSON
  factory UserModel.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'],
      email: json['email'] ?? '',
      image: json['image'],
      emailVerifiedAt: json['email_verified_at'],
      status: json['status'],
      provider: json['provider'],
      providerId: json['provider_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      phone: json['phone'],
      country: json['country'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      address: json['address'],
    );
  }

  /// Serialize to JSON (for saving locally)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'image': image,
      'email_verified_at': emailVerifiedAt,
      'status': status,
      'provider': provider,
      'provider_id': providerId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'phone': phone,
      'country': country,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'address': address,
    };
  }
}
