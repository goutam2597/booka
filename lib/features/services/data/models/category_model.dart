class CategoryModel {
  final int id;
  final String name;
  final String icon;
  final String backgroundColor;
  final String slug;
  final String image;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.backgroundColor,
    required this.slug,
    this.image = '',
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      image: json['mobail_image'] ?? '',
      icon: json['icon'] ?? '',
      backgroundColor: json['background_color'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}
