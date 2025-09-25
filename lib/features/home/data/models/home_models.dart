import 'package:bookapp_customer/features/services/data/models/category_model.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/vendors/models/admin_model.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_model.dart';

class SectionContent {
  final String categorySectionTitle;
  final String latestServiceSectionTitle;
  final String featuredServiceSectionTitle;
  final String vendorSectionTitle;
  final String heroBackgroundImg;
  final String heroTitle;
  final String heroSubtitle;
  final String heroText;

  SectionContent({
    required this.categorySectionTitle,
    required this.latestServiceSectionTitle,
    required this.featuredServiceSectionTitle,
    required this.vendorSectionTitle,
    required this.heroBackgroundImg,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.heroText,
  });

  factory SectionContent.fromJson(Map<String, dynamic> json) => SectionContent(
    categorySectionTitle:
        json['category_section_title']?.toString() ?? 'Categories',
    latestServiceSectionTitle:
        json['latest_service_section_title']?.toString() ?? 'Latest Services',
    featuredServiceSectionTitle:
        json['featured_service_section_title']?.toString() ??
        'Featured Services',
    vendorSectionTitle: json['vendor_section_title']?.toString() ?? 'Vendors',
    heroBackgroundImg: json['hero_section_background_img']?.toString() ?? '',
    heroTitle: json['hero_section_title']?.toString() ?? '',
    heroSubtitle: json['hero_section_subtitle']?.toString() ?? '',
    heroText: json['hero_section_text']?.toString() ?? '',
  );
}

class ProcessItem {
  final int id;
  final String title;
  final String text;
  final String icon;
  final String backgroundColor;

  ProcessItem({
    required this.id,
    required this.title,
    required this.text,
    required this.icon,
    required this.backgroundColor,
  });

  factory ProcessItem.fromJson(Map<String, dynamic> json) => ProcessItem(
    id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
    title: json['title']?.toString() ?? '',
    text: json['text']?.toString() ?? '',
    icon: json['icon']?.toString() ?? '',
    backgroundColor: json['background_color']?.toString() ?? '',
  );
}

class TestimonialItem {
  final int id;
  final String name;
  final String occupation;
  final String image;
  final String comment;
  final String rating;

  TestimonialItem({
    required this.id,
    required this.name,
    required this.occupation,
    required this.image,
    required this.comment,
    required this.rating,
  });

  factory TestimonialItem.fromJson(Map<String, dynamic> json) =>
      TestimonialItem(
        id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
        name: json['name']?.toString() ?? '',
        occupation: json['occupation']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
        comment: json['comment']?.toString() ?? '',
        rating: json['rating']?.toString() ?? '',
      );
}

class HomeResponse {
  final AdminModel admin;
  final SectionContent sectionContent;
  final List<CategoryModel> categories;
  final List<ServicesModel> featuredServices;
  final List<ServicesModel> latestServices; // from services.data
  final List<VendorModel> featuredVendors;
  final List<ProcessItem> processes;
  final List<TestimonialItem> testimonials;

  HomeResponse({
    required this.admin,
    required this.sectionContent,
    required this.categories,
    required this.featuredServices,
    required this.latestServices,
    required this.featuredVendors,
    required this.processes,
    required this.testimonials,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    final admin = AdminModel.fromJson(json['admin'] as Map<String, dynamic>);
    final section = SectionContent.fromJson(
      (json['sectionContent'] as Map?)?.cast<String, dynamic>() ?? {},
    );

    final List<CategoryModel> categories =
        (json['categories'] as List? ?? const [])
            .map(
              (e) => CategoryModel.fromJson((e as Map).cast<String, dynamic>()),
            )
            .toList();

    final List<ServicesModel> featured =
        (json['featured_services'] as List? ?? const [])
            .map(
              (e) => ServicesModel.fromFeaturedJson(
                (e as Map).cast<String, dynamic>(),
              ),
            )
            .toList();

  // services may come as a bare array or wrapped like { data: [...] }
  final dynamic servicesRaw = json['services'];
  final List latestList = servicesRaw is List
    ? servicesRaw
    : (servicesRaw is Map
      ? ((servicesRaw)['data'] as List?) ?? const []
      : const []);
  final List<ServicesModel> latestServices = latestList
        .map((e) => ServicesModel.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    final List<VendorModel> featuredVendors =
        (json['featuredVendors'] as List? ?? const [])
            .map(
              (e) => VendorModel.fromJson(
                (e as Map).cast<String, dynamic>(),
                admin: admin,
              ),
            )
            .toList();

    final processes = (json['processes'] as List? ?? const [])
        .map((e) => ProcessItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    final testimonials = (json['testimonials'] as List? ?? const [])
        .map(
          (e) => TestimonialItem.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList();

    return HomeResponse(
      admin: admin,
      sectionContent: section,
      categories: categories,
      featuredServices: featured,
      latestServices: latestServices,
      featuredVendors: featuredVendors,
      processes: processes,
      testimonials: testimonials,
    );
  }
}
