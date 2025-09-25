import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/vendors/models/admin_model.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_details_model.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';

class VendorModel {
  final int id;
  final String? photo;
  final String? email;
  final String? phone;
  final String username;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String address;
  final String? status;
  final String? verified;
  final String country;
  final String? details;
  final String? createdAt;
  final String? updatedAt;
  final String avgRating;
  final String? totalAppointment;
  final List<ServicesModel> services;
  final List<VendorDetailsModel> vendorDetails;

  final AdminModel? admin;

  const VendorModel({
    required this.id,
    this.photo,
    this.email,
    this.phone,
    required this.username,
    this.name,
    this.firstName,
    this.lastName,
    required this.address,
    this.status,
    this.verified,
    required this.country,
    this.details,
    this.createdAt,
    this.updatedAt,
    required this.avgRating,
    this.totalAppointment,
    this.services = const [],
    this.vendorDetails = const [],
    this.admin,
  });

  // Returns a succinct label. Prioritizes the actual vendor `username`,
  // then known names, then admin username, finally 'Admin'.
  String get labelPreferUsername {
    final u = (username).trim();
    if (u.isNotEmpty) return u;

    final n = (name ?? '').trim();
    if (n.isNotEmpty) return n;

    final full = [
      (firstName ?? '').trim(),
      (lastName ?? '').trim(),
    ].where((p) => p.isNotEmpty).join(' ').trim();
    if (full.isNotEmpty) return full;

    final aUser = (admin?.username ?? '').trim();
    if (aUser.isNotEmpty) return aUser;

    return 'Admin';
  }

  String _trimmed(String? value) => value?.trim() ?? '';

  String get displayName {
    final directName = _trimmed(name);
    if (directName.isNotEmpty) return directName;

    for (final detail in vendorDetails) {
      final detailName = _trimmed(detail.vendorInfo?.name);
      if (detailName.isNotEmpty) return detailName;
    }

    final fullName = [
      _trimmed(firstName),
      _trimmed(lastName),
    ].where((part) => part.isNotEmpty).join(' ').trim();
    if (fullName.isNotEmpty) return fullName;

    final uname = _trimmed(username);
    if (uname.isNotEmpty) {
      return uname;
    }

    final adminFullName = [
      _trimmed(admin?.firstName),
      _trimmed(admin?.lastName),
    ].where((part) => part.isNotEmpty).join(' ').trim();
    if (adminFullName.isNotEmpty) return adminFullName;

    final adminUsername = _trimmed(admin?.username);
    if (adminUsername.isNotEmpty) return adminUsername;

    return 'Admin';
  }

  static String _resolvePhoto(dynamic value) {
    if (value == null) {
      return _fallbackPhoto;
    }
    final str = value.toString().trim();
    if (str.isEmpty) return _fallbackPhoto;
    if (!(str.startsWith('http://') || str.startsWith('https://'))) {
      return _fallbackPhoto;
    }
    return str;
  }

  static const String _fallbackPhoto = AssetsPath.defaultVendor;

  factory VendorModel.fromJson(Map<String, dynamic> json, {AdminModel? admin}) {
    // services
    final List<ServicesModel> services = (json['services'] is List)
        ? (json['services'] as List)
              .map((e) => ServicesModel.fromJson(e as Map<String, dynamic>))
              .toList()
        : const [];

    // vendor_details
    final List<VendorDetailsModel> vendorDetails =
        (json['vendor_details'] is List)
        ? (json['vendor_details'] as List)
              .map(
                (e) => VendorDetailsModel.fromJson(e as Map<String, dynamic>),
              )
              .toList()
        : const [];

    // admin (if provided either via param or embedded json)
    final adminJson = json['admin'];
    final parsedAdmin =
        admin ??
        (adminJson is Map<String, dynamic>
            ? AdminModel.fromJson(adminJson)
            : null);

    return VendorModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      photo: _resolvePhoto(json['photo']),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      username: json['username']?.toString() ?? '',
      name: (json['name'] ?? json['vendor_name'] ?? json['company_name'])
          ?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString(),
      verified: json['email_verified_at']?.toString(),
      country: json['country']?.toString() ?? '',
      details: json['details']?.toString(),
      createdAt: (json['created_at'] ?? json['createdAt'])?.toString(),
      updatedAt: (json['updated_at'] ?? json['updatedAt'])?.toString(),
      avgRating:
          (json['averageRating'] ?? json['avg_rating'])?.toString() ?? '',
      totalAppointment: json['total_appointment']?.toString(),
      services: services,
      vendorDetails: vendorDetails,
      admin: parsedAdmin,
    );
  }

  factory VendorModel.empty() => VendorModel(
    id: 0,
    photo: _fallbackPhoto,
    email: null,
    phone: null,
    username: 'Admin',
    name: 'Admin',
    address: 'null',
    status: '1',
    verified: '',
    country: 'Country',
    details: 'Details',
    createdAt: null,
    updatedAt: null,
    avgRating: '0.0',
    totalAppointment: '0',
    services: const [],
    vendorDetails: const [],
    admin: AdminModel.empty(),
  );
}
