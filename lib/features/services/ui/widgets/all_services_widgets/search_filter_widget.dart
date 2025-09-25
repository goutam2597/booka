import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_button_widget.dart';
import 'package:bookapp_customer/features/services/providers/services_search_filter_provider.dart';
import 'package:bookapp_customer/features/services/ui/widgets/all_services_widgets/price_range_slider.dart';
import 'package:bookapp_customer/features/services/ui/widgets/all_services_widgets/sort_by_dropdown_widget.dart';
import 'package:bookapp_customer/features/services/data/models/services_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SearchFilterWidget extends StatelessWidget {
  final List<String> categories;
  final List<String> ratings;
  final ServicesFilter? initial;
  const SearchFilterWidget({
    super.key,
    this.categories = const ['All Categories'],
    this.ratings = const ['All', '5', '4', '3', '2', '1'],
    this.initial,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final filterProvider = context.read<ServicesSearchFilterProvider>();
    if (initial != null && !filterProvider.didHydrate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final mounted = context.mounted;
        if (!mounted) return;
        final prov = context.read<ServicesSearchFilterProvider>();
        if (!prov.didHydrate) {
          prov.hydrateFromFilter(initial!);
        }
      });
    }
    return Consumer<ServicesSearchFilterProvider>(
      builder: (context, p, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: double.infinity,
                maxHeight: size.height * 0.75,
              ),
              child: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      Divider(thickness: 1.5, color: Colors.grey.shade300),
                      _buildSectionTitle('Categories'),
                      _buildHorizontalItemList(
                        categories,
                        width: 120,
                        selectedItem: p.category,
                        onSelect: (value) =>
                            p.setCategory(value == 'All' ? null : value),
                      ),
                      _buildSectionTitle('Sort By'),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SortByDropdownWidget(
                          initial: _sortToKey(p.sort),
                          onChanged: (key) => p.setSort(_keyToSort(key)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Price'),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: PriceRangeSlider(
                          min: 0,
                          max: 100000,
                          initialMin: p.minPrice,
                          initialMax: p.maxPrice,
                          onChanged: (v) => p.setPriceRange(v.start, v.end),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Ratings'),
                      _buildHorizontalItemList(
                        ratings,
                        width: 80,
                        isRating: true,
                        selectedItem: p.ratingKey,
                        onSelect: (value) => p.setRatingKey(value),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Close'.tr,
                                    style: AppTextStyles.bodyLarge,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: CustomButtonWidget(
                                  text: 'Apply'.tr,
                                  onPressed: () {
                                    Navigator.pop(context, p.buildFilter());
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter'.tr,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(AssetsPath.cancelSvg, width: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.tr,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.colorText,
        ),
      ),
    );
  }

  Widget _buildHorizontalItemList(
    List<String> items, {
    required double width,
    bool isRating = false,
    required String? selectedItem,
    required Function(String value) onSelect,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: items.map((item) {
          // Ratings & Categories: highlight 'All' when selectedItem == null
          final bool isSelected =
              (selectedItem == null && item == 'All') || (item == selectedItem);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(item),
              child: _buildSelectableItemCard(
                item,
                width,
                isRating,
                isSelected,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectableItemCard(
    String text,
    double width,
    bool isRating,
    bool isSelected,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: isSelected ? AppColors.primaryColor : Colors.white,
      child: SizedBox(
        width: width,
        height: 50,
        child: Center(
          child: isRating
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade600, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
        ),
      ),
    );
  }

  String _sortToKey(ServicesSort s) {
    switch (s) {
      case ServicesSort.priceLowToHigh:
        return 'Price: Low to High';
      case ServicesSort.priceHighToLow:
        return 'Price: High to Low';
      case ServicesSort.ratingHighToLow:
        return 'Rating: High to Low';
      case ServicesSort.newest:
        return 'Newest';
      case ServicesSort.relevance:
        return 'Relevance';
    }
  }

  ServicesSort _keyToSort(String key) {
    switch (key) {
      case 'Price: Low to High':
        return ServicesSort.priceLowToHigh;
      case 'Price: High to Low':
        return ServicesSort.priceHighToLow;
      case 'Rating: High to Low':
        return ServicesSort.ratingHighToLow;
      case 'Newest':
        return ServicesSort.newest;
      case 'Relevance':
      default:
        return ServicesSort.relevance;
    }
  }
}
