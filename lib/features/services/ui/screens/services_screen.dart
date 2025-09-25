import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_icon_button_widgets.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_search_bar_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/network_app_logo.dart';
import 'package:bookapp_customer/features/home/providers/notification_provider.dart';
import 'package:bookapp_customer/features/home/ui/widgets/service_card_widget.dart';
import 'package:bookapp_customer/features/services/providers/services_provider.dart';
import 'package:bookapp_customer/features/services/ui/widgets/all_services_widgets/skeleton_grid.dart';
import 'package:bookapp_customer/features/services/ui/widgets/services_card_widget_for_grid.dart';
import 'package:bookapp_customer/features/services/data/models/services_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesProvider>().init();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final p = context.read<ServicesProvider>();
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !p.isLoading) {
      p.loadMore();
    }
  }

  Future<void> _handleRefresh() async {
    await context.read<ServicesProvider>().refresh();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServicesProvider>();
    final items = provider.displayed;
    final features = provider.featured;
    final hasUnread = context.select<NotificationProvider, bool>(
      (p) => p.hasUnread,
    );
    return Scaffold(
      appBar: _buildAppBar(context, hasUnread),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: AppColors.primaryColor,
        onRefresh: _handleRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            const spacing = 8.0;
            const padding = 16.0;
            int crossAxisCount;

            if (screenWidth >= 1000) {
              crossAxisCount = 6;
            } else if (screenWidth >= 800) {
              crossAxisCount = 5;
            } else if (screenWidth >= 700) {
              crossAxisCount = 4;
            } else if (screenWidth >= 600) {
              crossAxisCount = 3;
            } else if (screenWidth >= 500) {
              crossAxisCount = 2;
            } else if (screenWidth >= 400) {
              crossAxisCount = 2;
            } else if (screenWidth >= 300) {
              crossAxisCount = 2;
            } else {
              crossAxisCount = 1;
            }

            final itemWidth =
                (screenWidth -
                    (padding * 2) -
                    (spacing * (crossAxisCount - 1))) /
                crossAxisCount;
            final isInitialLoading = provider.isLoading && items.isEmpty;

            return SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Search
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomSearchBarWidget(
                            hintText: 'Search Service',
                            onSearch: provider.search,
                            showFilter: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '(${provider.totalCount})',
                          style: AppTextStyles.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Services Found'.tr,
                          style: AppTextStyles.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Active filter chips
                  if (provider.filter != ServicesFilter.empty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _buildActiveFilterChips(context, provider),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Skeleton
                  if (isInitialLoading)
                    SkeletonGrid(
                      itemWidth: itemWidth,
                      crossAxisCount: crossAxisCount,
                      spacing: spacing,
                    ),
                  // Empty
                  if (!provider.isLoading && items.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('No services available'.tr)),
                    ),
                  if (features.isNotEmpty)
                    SizedBox(
                      height: 340,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: features.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              left: index == 0 ? 16 : 8,
                              right: 8,
                            ),
                            child: SizedBox(
                              width: 320,
                              child: ServiceCardWidget(
                                item: features[index],
                                color: AppColors.primaryColor.withAlpha(10),
                                border: AppColors.primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (items.isNotEmpty)
                    AnimationLimiter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: MasonryGridView.count(
                          controller: null,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 700),
                              child: ScaleAnimation(
                                curve: Curves.easeInOutCubic,
                                scale: 0.98,
                                child: SlideAnimation(
                                  verticalOffset: 16,
                                  curve: Curves.easeInOutCubic,
                                  child: FadeInAnimation(
                                    curve: Curves.easeInOutCubic,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        Get.toNamed(
                                          AppRoutes.serviceDetails,
                                          arguments: {
                                            'slug': item.slug,
                                            'id': item.id,
                                          },
                                        );
                                      },
                                      child: ServicesCardWidgetForGrid(
                                        item: item,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  // Pagination loader
                  if (provider.isLoading && items.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CustomCPI()),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool hasUnread) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NetworkAppLogo(width: 120, height: 24),
            Row(
              children: [
                Stack(
                  children: [
                    CustomIconButtonWidget(
                      assetPath: AssetsPath.notificationIconSvg,
                      onTap: () {
                        Get.toNamed(AppRoutes.notifications);
                        if (mounted) {
                          context.read<NotificationProvider>().refresh();
                        }
                      },
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ----- FILTER CHIPS -----
  List<Widget> _buildActiveFilterChips(
    BuildContext context,
    ServicesProvider provider,
  ) {
    final f = provider.filter;
    final chips = <Widget>[];

    void updateFilter(ServicesFilter nf) {
      // If only one chip left → clear all instead
      if (chips.length == 1) {
        context.read<ServicesProvider>().clearFilter();
      } else {
        context.read<ServicesProvider>().applyFilter(nf);
      }
    }

    // Category
    if (f.category != null && f.category!.isNotEmpty) {
      chips.add(
        _chip(
          'Category: ${f.category}',
          onDeleted: () {
            updateFilter(
              ServicesFilter(
                category: null,
                minRating: f.minRating,
                minPrice: f.minPrice,
                maxPrice: f.maxPrice,
                sort: f.sort,
              ),
            );
          },
        ),
      );
    }

    // Rating
    if (f.minRating != null) {
      chips.add(
        _chip(
          'Rating: ${f.minRating}★+',
          onDeleted: () {
            updateFilter(
              ServicesFilter(
                category: f.category,
                minRating: null,
                minPrice: f.minPrice,
                maxPrice: f.maxPrice,
                sort: f.sort,
              ),
            );
          },
        ),
      );
    }

    // Price Min
    if (f.minPrice != null) {
      chips.add(
        _chip(
          'Min: ${f.minPrice!.toStringAsFixed(0)}',
          onDeleted: () {
            updateFilter(
              ServicesFilter(
                category: f.category,
                minRating: f.minRating,
                minPrice: null,
                maxPrice: f.maxPrice,
                sort: f.sort,
              ),
            );
          },
        ),
      );
    }

    // Price Max
    if (f.maxPrice != null) {
      chips.add(
        _chip(
          'Max: ${f.maxPrice!.toStringAsFixed(0)}',
          onDeleted: () {
            updateFilter(
              ServicesFilter(
                category: f.category,
                minRating: f.minRating,
                minPrice: f.minPrice,
                maxPrice: null,
                sort: f.sort,
              ),
            );
          },
        ),
      );
    }

    // Sort
    if (f.sort != ServicesSort.relevance) {
      chips.add(
        _chip(
          'Sort: ${_sortLabel(f.sort)}',
          onDeleted: () {
            updateFilter(
              ServicesFilter(
                category: f.category,
                minRating: f.minRating,
                minPrice: f.minPrice,
                maxPrice: f.maxPrice,
                sort: ServicesSort.relevance,
              ),
            );
          },
        ),
      );
    }
    return chips;
  }

  Widget _chip(String label, {required VoidCallback onDeleted}) {
    return Chip(
      backgroundColor: Colors.white,
      label: Text(label),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 18),
    );
  }

  String _sortLabel(ServicesSort s) {
    switch (s) {
      case ServicesSort.priceLowToHigh:
        return 'Price Low to High';
      case ServicesSort.priceHighToLow:
        return 'Price High to Low';
      case ServicesSort.ratingHighToLow:
        return 'Rating';
      case ServicesSort.newest:
        return 'Newest';
      case ServicesSort.relevance:
        return 'Relevance';
    }
  }
}
