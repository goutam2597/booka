import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/vendors/models/admin_model.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_model.dart';

class ServiceDetailsModel {
  final ServiceDetails details;
  final List<ServicesModel> relatedServices;
  final AdminModel? admin;
  final List<WorkingDay> allDays;
  final List<Review> reviews;

  ServiceDetailsModel({
    required this.details,
    required this.relatedServices,
    this.admin,
    required this.allDays,
    required this.reviews,
  });

  factory ServiceDetailsModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailsModel(
      details: ServiceDetails.fromJson(json['details'] as Map<String, dynamic>),
      relatedServices: (json['related_services'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((i) => ServicesModel.fromJson(i))
          .toList(),
      admin: json['admin'] != null
          ? AdminModel.fromJson(json['admin'] as Map<String, dynamic>)
          : null,
      allDays: (json['allDays'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((i) => WorkingDay.fromJson(i))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((i) => Review.fromJson(i))
          .toList(),
    );
  }
}

class ServiceDetails {
  final int id;
  final String? price;
  final String? previousPrice;
  final String? averageRating;
  final String? lat;
  final String? lon;
  final Content content;
  final List<SliderImage> sliderImages;
  final VendorInfo? vendorInfo;
  final VendorModel? vendor;
  final List<Review> reviews;

  ServiceDetails({
    required this.id,
    this.price,
    this.previousPrice,
    this.averageRating,
    this.lat,
    this.lon,
    required this.content,
    required this.sliderImages,
    this.vendorInfo,
    this.vendor,
    required this.reviews,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    final contentList = (json['content'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return ServiceDetails(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      price: json['formatted_price']?.toString(),
      previousPrice: json['formatted_prev_price']?.toString(),
      lat: json['latitude']?.toString(),
      lon: json['longitude']?.toString(),
      averageRating: json['average_rating']?.toString(),
      content: contentList.isNotEmpty ? Content.fromJson(contentList.first) : Content.empty(),
      sliderImages: (json['slider_image'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((i) => SliderImage.fromJson(i))
          .toList(),
      vendorInfo: json['vendor_info'] != null
          ? VendorInfo.fromJson(json['vendor_info'] as Map<String, dynamic>)
          : null,
      vendor: json['vendor'] != null
          ? VendorModel.fromJson(json['vendor'] as Map<String, dynamic>)
          : null,
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((i) => Review.fromJson(i))
          .toList(),
    );
  }
}

class Content {
  final String name;
  final String id;
  final String description;
  final String features;
  final String address;
  final String categoryId;

  Content({
    required this.name,
    required this.id,
    required this.description,
    required this.address,
    required this.features,
    required this.categoryId,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      name: json['name']?.toString() ?? '',
      id: json['service_id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      features: json['features']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
    );
  }

  factory Content.empty() => Content(
    name: '',
    id: '',
    description: '',
    address: '',
    features: '',
    categoryId: '',
  );
}

class SliderImage {
  final String image;

  SliderImage({required this.image});

  factory SliderImage.fromJson(Map<String, dynamic> json) {
    return SliderImage(image: json['image']?.toString() ?? '');
  }
}

class VendorInfo {
  final String name;
  final String? address;

  VendorInfo({required this.name, this.address});

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
    );
  }
}


class WorkingDay {
  final int dayId;
  final String minTime;
  final String maxTime;
  final String day;
  final String isWeekend;
  final String indx;

  WorkingDay({
    required this.dayId,
    required this.minTime,
    required this.maxTime,
    required this.day,
    required this.isWeekend,
    required this.indx,
  });

  factory WorkingDay.fromJson(Map<String, dynamic> json) {
    return WorkingDay(
      dayId: json['dayId'] is int ? json['dayId'] as int : int.tryParse('${json['dayId']}') ?? 0,
      minTime: json['minTime']?.toString() ?? '',
      maxTime: json['maxTime']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      isWeekend: json['is_weekend']?.toString() ?? '',
      indx: json['indx']?.toString() ?? '',
    );
  }
}

/// NEW: Review model
class Review {
  final String? id;
  final String? userId;
  final String? vendorId;
  final String? serviceId;
  final String comment;
  final String? rating;
  final String? createdAt;
  final String? updatedAt;
  final ReviewUser? user;

  Review({
    this.id,
    this.userId,
    this.vendorId,
    this.serviceId,
    required this.comment,
    this.rating,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return Review(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      vendorId: json['vendor_id']?.toString(),
      serviceId: json['service_id']?.toString(),
      comment: (json['comment'] ?? '').toString(),
      rating: json['rating']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      user: (userJson is Map<String, dynamic>) ? ReviewUser.fromJson(userJson) : null,
    );
  }
}

/// NEW: Minimal user payload embedded in a review
class ReviewUser {
  final String name;
  final String? email;
  final String? image;
  final String? address;


  ReviewUser({
    required this.name,
    this.email,
    this.image,
    this.address,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      image: json['image_url']?.toString(),
      address: json['address']?.toString(),
    );
  }
}
