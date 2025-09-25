import 'package:bookapp_customer/features/services/data/models/category_model.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/vendors/models/admin_model.dart';

class ServicesDataModel {
  final AdminModel admin;
  final List<CategoryModel> categories;
  final List<ServicesModel> featuredServices;
  final List<ServicesModel> allServices;

  ServicesDataModel({
    required this.admin,
    required this.categories,
    required this.featuredServices,
    required this.allServices,
  });

  factory ServicesDataModel.fromJson(Map<String, dynamic> json) {
    return ServicesDataModel(
      admin: AdminModel.fromJson(json['admin']),
      categories: (json['categories'] as List)
          .map((i) => CategoryModel.fromJson(i))
          .toList(),
      featuredServices: (json['featuredServices'] as List)
          .map((i) => ServicesModel.fromJson(i))
          .toList(),
      allServices: (json['services'] as List)
          .map((i) => ServicesModel.fromJson(i))
          .toList(),
    );
  }
}
