import 'package:bookapp_customer/features/services/data/models/category_model.dart';
import 'package:bookapp_customer/features/vendors/models/admin_model.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_model.dart';

class ServicesModel {
  final int id;
  final int vendorId;
  final String slug;
  final String name;
  final String? serviceImage;
  final String? previousPrice;
  final String? averageRating;
  final String? address;
  final String categoryName;
  final String categorySlug;
  final String price;
  final VendorModel? vendor;
  final AdminModel? admin;
  final CategoryModel? category;
  final bool isFeatured;

  ServicesModel({
    required this.id,
    required this.vendorId,
    required this.slug,
    required this.name,
    this.serviceImage,
    this.previousPrice,
    this.averageRating,
    this.address,
    required this.categoryName,
    required this.categorySlug,
    required this.price,
    required this.vendor,
    this.admin,
    this.isFeatured = false,
    this.category,
  });

  static int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  static CategoryModel? _buildCategory(Map<String, dynamic> json) {
    final nested = json['categories'];

    // Prefer flattened fields if available
    final catIdRaw =
        json['categoryid'] ??
        json['category_id'] ??
        json['categoryId'] ??
        nested?['id'];
    final catName =
        json['categoryName'] ?? json['category_name'] ?? nested?['name'];
    final catSlug =
        json['categorySlug'] ??
        json['category_slug'] ??
        json['categoryslug'] ??
        nested?['slug'];
    final catIcon = json['categoryIcon'] ?? nested?['icon'];
    final catImage = nested?['image'];
    final bg = nested?['background_color'];

    if (catIdRaw == null &&
        catName == null &&
        catSlug == null &&
        catIcon == null) {
      return null;
    }

    final catJson = <String, dynamic>{
      'id': _toInt(catIdRaw ?? 0),
      'name': catName ?? '',
      'slug': catSlug ?? '',
      'icon': catIcon,
      'image': catImage,
      'background_color': bg,
    };

    try {
      return CategoryModel.fromJson(catJson);
    } catch (_) {
      return CategoryModel.fromJson({
        'id': _toInt(catIdRaw ?? 0),
        'name': catName ?? '',
        'slug': catSlug ?? '',
        'icon': catIcon,
      });
    }
  }

  factory ServicesModel.fromJson(Map<String, dynamic> json) {
    final vendorJson = json['vendor'];
    final adminJson = json['admin'];

    return ServicesModel(
      id: json['id'],
      vendorId: _toInt(
        json['vendor_id'] ?? json['vendorId'] ?? json['vendorid'],
      ),
      slug: json['slug'],
      name: json['name'],
      serviceImage: json['service_image'],
      // price: '${json['price']}',
      previousPrice: json['formatted_prev_price'] ?? json['prev_price'],
      averageRating: json['average_rating'],
      address: json['address'],
      categoryName: json['categoryName'] ?? json['category_name'] ?? 'N/A',
      categorySlug: json['categorySlug'] ?? json['category_slug'] ?? '',
      price: json['formatted_price'] ?? json['formattedPrice'],
      vendor: vendorJson != null ? VendorModel.fromJson(vendorJson) : null,
      admin: adminJson != null ? AdminModel.fromJson(adminJson) : null,
      isFeatured: false,
      category: _buildCategory(json),
    );
  }

  /// For `featuredServices` items (may omit vendor/admin; mark as featured)
  factory ServicesModel.fromFeaturedJson(Map<String, dynamic> json) {
    final vendorJson = json['vendor'];
    final adminJson = json['admin'];

    return ServicesModel(
      id: json['id'],
      vendorId: _toInt(
        json['vendor_id'] ?? json['vendorId'] ?? json['vendorid'],
      ),
      slug: json['slug'],
      name: json['name'],
      serviceImage: json['service_image'],
      previousPrice: json['formatted_prev_price'] ?? json['prev_price'],
      averageRating: json['average_rating'],
      address: json['address'],
      categoryName: json['categoryName'] ?? json['category_name'] ?? 'N/A',
      categorySlug: json['categorySlug'] ?? json['category_slug'] ?? '',
      price: json['formatted_price'] ?? json['formattedPrice'],
      vendor: vendorJson != null ? VendorModel.fromJson(vendorJson) : null,
      admin: adminJson != null ? AdminModel.fromJson(adminJson) : null,
      isFeatured: true,
      category: _buildCategory(json),
    );
  }
}
