import 'package:bookapp_customer/features/account/models/user_model.dart';

class DashboardModel {
  final int wishlistsCount;
  final int appointmentsCount;
  final int ordersCount;
  final String userName;
  final String bgImg;
  final String userEmail;
  final String? userPhoto;
  final String pageTitle;
  final UserModel userModel;

  DashboardModel(
      this.userModel, {
        required this.wishlistsCount,
        required this.appointmentsCount,
        required this.ordersCount,
        required this.userName,
        required this.bgImg,
        required this.userEmail,
        this.userPhoto,
        required this.pageTitle,
      });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    // Accepts full response or just data
    final data = json['data'] ?? json;
    final user = data['authUser'] ?? {};

    // Try the expected nested key first, then some sensible fallbacks.
    String extractPageTitle(Map<String, dynamic> src) {
      final heading = src['pageHeading'];
      if (heading is Map) {
        final t = heading['dashboard_page_title'];
        if (t is String) return t;
      }
      // Fallbacks if structure differs or key missing
      return (src['dashboard_page_title'] as String?) ??
          (src['page_title'] as String?) ??
          '';
    }

    return DashboardModel(
      UserModel.fromJson(user),
      wishlistsCount: data['wishlistsCount'] ?? 0,
      appointmentsCount: data['appointmentsCount'] ?? 0,
      ordersCount: data['ordersCount'] ?? 0,
      userName: user['name'] ?? '',
      bgImg: data['bgImg'] ?? '',
      userEmail: user['email'] ?? '',
      userPhoto: user['image'],
      pageTitle: extractPageTitle(Map<String, dynamic>.from(data)),
    );
  }
}
