import 'package:bookapp_customer/features/services/data/models/category_model.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';

import 'vendor_model.dart';

class VendorInfoModel {
  final int id;
  final String vendorId;
  final String languageId;
  final String name;
  final String country;
  final String? city;
  final String? state;
  final String? zipCode;
  final String address;
  final String? details;
  final String createdAt;
  final String updatedAt;

  VendorInfoModel({
    required this.id,
    required this.vendorId,
    required this.languageId,
    required this.name,
    required this.country,
    this.city,
    this.state,
    this.zipCode,
    required this.address,
    this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorInfoModel.fromJson(Map<String, dynamic> json) {
    return VendorInfoModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      vendorId: json['vendor_id']?.toString() ?? '',
      languageId: json['language_id']?.toString() ?? '',
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      address: json['address'] ?? '',
      details: json['details'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class VendorDetailsModel {
  final VendorInfoModel? vendorInfo;
  final int totalService;
  final VendorModel vendor;
  final String? vendorDetails;
  final String vendorAddress;
  final List<CategoryModel> categories;
  final List<ServicesModel> services;
  final Map<String, dynamic>? secInfo;
  final Map<String, dynamic>? currencyInfo;
  final Map<String, dynamic>? info;
  final String? stripeKey;
  final String? authorizeUrl;
  final String? authorizeLoginId;
  final String? authorizePublicKey;
  final String? bgImg;
  final Map<String, dynamic>? language;

  VendorDetailsModel({
    this.vendorInfo,
    required this.totalService,
    required this.vendor,
    this.vendorDetails,
    required this.vendorAddress,
    required this.categories,
    required this.services,
    this.secInfo,
    this.currencyInfo,
    this.info,
    this.stripeKey,
    this.authorizeUrl,
    this.authorizeLoginId,
    this.authorizePublicKey,
    this.bgImg,
    this.language,
  });

  factory VendorDetailsModel.fromJson(Map<String, dynamic> json) {
    return VendorDetailsModel(
      vendorInfo: json['vendorInfo'] != null
          ? VendorInfoModel.fromJson(json['vendorInfo'])
          : null,
      totalService: int.tryParse(json['total_service'].toString()) ?? 0,
      vendor: VendorModel.fromJson(json['vendor']),
      vendorDetails: json['vendor_details'],
      vendorAddress: json['vendor_address'] ?? '',
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e))
              .toList() ??
          [],
      services:
          (json['services'] as List<dynamic>?)
              ?.map((e) => ServicesModel.fromJson(e))
              .toList() ??
          [],
      secInfo: json['secInfo'] != null
          ? Map<String, dynamic>.from(json['secInfo'])
          : null,
      currencyInfo: json['currencyInfo'] != null
          ? Map<String, dynamic>.from(json['currencyInfo'])
          : null,
      info: json['info'] != null
          ? Map<String, dynamic>.from(json['info'])
          : null,
      stripeKey: json['stripe_key'],
      authorizeUrl: json['authorizeUrl'],
      authorizeLoginId: json['authorize_login_id'],
      authorizePublicKey: json['authorize_public_key'],
      bgImg: json['bgImg'],
      language: json['language'] != null
          ? Map<String, dynamic>.from(json['language'])
          : null,
    );
  }
}
