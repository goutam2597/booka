import 'package:bookapp_customer/app/assets_path.dart';

class AdminModel {
  final int id;
  final String firstName;
  final String lastName;
  final String image;
  final String username;
  final String email;
  final String address;
  final String details;

  const AdminModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.image = AssetsPath.defaultVendor,
    required this.username,
    required this.email,
    required this.address,
    required this.details,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
    );
  }

  factory AdminModel.empty() => const AdminModel(
    id: 0,
    firstName: '',
    lastName: '',
    image: AssetsPath.defaultVendor,
    username: 'admin',
    email: '',
    address: '',
    details: '',
  );
}
