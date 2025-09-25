class WishlistModel {
  final int id;
  final int userId;
  final int vendorId;
  final int serviceId;
  final String createdAt;
  final String updatedAt;
  final String serviceImage;
  final String? averageRating;
  final String price;
  final String name;
  final String slug;
  final String wishlistPageTitle;

  WishlistModel({
    required this.id,
    required this.userId,
    required this.vendorId,
    required this.serviceId,
    required this.createdAt,
    required this.updatedAt,
    required this.serviceImage,
    required this.averageRating,
    required this.price,
    required this.name,
    required this.slug,
    required this.wishlistPageTitle,
  });

  /// Optional [pageTitle] lets you pass the parent `data.pageHeading.wishlist_page_title`
  factory WishlistModel.fromJson(Map<String, dynamic> json, {String? pageTitle}) {
    return WishlistModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      vendorId: int.tryParse(json['vendor_id'].toString()) ?? 0,
      serviceId: int.tryParse(json['service_id'].toString()) ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      serviceImage: json['service_image']?.toString() ?? '',
      averageRating: json['average_rating']?.toString(),
      price: json['price']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      wishlistPageTitle: (json['wishlist_page_title'] ?? pageTitle ?? '').toString(),
    );
  }
}
