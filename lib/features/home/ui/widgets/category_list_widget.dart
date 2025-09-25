import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../services/data/models/category_model.dart';

class CategoryListWidget extends StatelessWidget {
  final void Function(CategoryModel) onCategoryTap; // updated
  final List<CategoryModel> categories;

  const CategoryListWidget({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(right: 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final item = categories[index];
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 16 : 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onCategoryTap(item),
            child: _buildCategoryItem(item),
          ),
        );
      },
    );
  }

  /// Builds a single category card
  Widget _buildCategoryItem(CategoryModel item) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade50,
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CachedNetworkImage(imageUrl: item.image,height: 48,width: 48,),
          const SizedBox(height: 8),
          Text(
            textAlign: TextAlign.center,
            item.name,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
