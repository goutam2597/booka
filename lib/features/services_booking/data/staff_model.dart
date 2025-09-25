class StaffModel {
  final int id;
  final String name;
  final String email;
  final String? image;
  final String? username;
  final int vendorId;
  final int adminId;
  final bool isFallback;
  final String? kind;

  StaffModel({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    this.username,
    required this.vendorId,
    required this.adminId,
    this.isFallback = false,
    this.kind,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      image: json['image'] as String?,
      username: json['username'],
      vendorId: int.tryParse(json['vendor_id']?.toString() ?? '1') ?? 1,
      adminId: int.tryParse(json['admin_id']?.toString() ?? '1') ?? 1,
      isFallback: json['is_fallback'] == true,
      kind: json['kind'],
    );
  }
}
