import 'package:bookapp_customer/features/services/providers/service_details_ui_provider.dart';
import 'package:bookapp_customer/features/services/ui/widgets/s_details_widgets/bootm_bar.dart';
import 'package:bookapp_customer/features/services/ui/widgets/s_details_widgets/custom_tab_bar_widget.dart';
import 'package:bookapp_customer/features/services/ui/widgets/s_details_widgets/service_details_slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/features/services/data/models/category_model.dart';
import 'package:bookapp_customer/features/services/data/models/service_details_model.dart';
import 'package:bookapp_customer/features/services/ui/widgets/star_rating_widget.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import 'details_app_bar.dart';
import 'related_services_section.dart';

class DetailsScaffold extends StatelessWidget {
  const DetailsScaffold({
    super.key,
    required this.details,
    required this.selectedIndex,
    required this.relatedViewMode,
  });

  final ServiceDetailsModel details;
  final ValueNotifier<int> selectedIndex;
  final ValueNotifier<RelatedViewMode> relatedViewMode;

  @override
  Widget build(BuildContext context) {
    final serviceData = details.details;
    final images = serviceData.sliderImages.map((e) => e.image).toList();

    return Scaffold(
      appBar: const DetailsAppBar(),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageCarousel(
                      imgList: images,
                      selectedIndex: selectedIndex,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (details.relatedServices.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    final first = details.relatedServices.first;
                                    final categoryModel = CategoryModel(
                                      id: first.id,
                                      name: first.categoryName,
                                      slug: first.categorySlug,
                                      icon: '',
                                      backgroundColor: '',
                                    );
                                    Get.toNamed(
                                      AppRoutes.category,
                                      arguments: categoryModel,
                                    );
                                  },
                                  child: Text(
                                    details.relatedServices.isNotEmpty
                                        ? details
                                              .relatedServices
                                              .first
                                              .categoryName
                                        : 'Category'.tr,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  'Category'.tr,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              const Spacer(),
                              RatingStarsWidget(
                                showReviews: false,
                                reviews: '',
                                rating: serviceData.averageRating ?? '0.0',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            serviceData.content.name,
                            style: AppTextStyles.headingSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.colorText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            serviceData.content.address,
                            style: AppTextStyles.bodyLargeGrey.copyWith(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "${serviceData.price}",
                                style: AppTextStyles.headingLarge.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                serviceData.previousPrice ?? '0',
                                style: AppTextStyles.headingMedium.copyWith(
                                  color: Colors.grey.shade500,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomTabBarWidget(tabDetails: details),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // Related services (toggle List/Grid)
                    RelatedServicesSection(
                      services: details.relatedServices,
                      viewMode: relatedViewMode,
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          BottomBar(service: details),
        ],
      ),
    );
  }
}
