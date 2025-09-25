import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_button_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services/ui/widgets/star_rating_widget.dart';
import 'package:bookapp_customer/features/wishlist/providers/wishlist_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/routes/app_routes.dart';

class ServicesCardWidgetForGrid extends StatelessWidget {
  final ServicesModel item;
  const ServicesCardWidgetForGrid({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WishlistProvider>();
    final bool isSaved = provider.isInWishlist(item.id);

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    final cardWidth = isTablet
        ? (screenWidth / 5) - 32
        : (screenWidth / 2) - 24;
    final imageHeight = isTablet ? 160.0 : 140.0;
    final padding = isTablet ? 12.0 : 8.0;

    Future<void> toggleWishlist() async {
      if (isSaved) {
        final res = await context.read<WishlistProvider>().removeByServiceId(
          item.id,
        );

        if (context.mounted) {
          CustomSnackBar.show(
            context,
            res.message,
            snackPosition: SnackPosition.TOP,
            title: res.ok ? 'Success' : 'Ops!',
          );
        }
      } else {
        final res = await context.read<WishlistProvider>().addByServiceId(
          item.id,
        );
        if (context.mounted) {
          CustomSnackBar.show(
            context,
            res.message,
            snackPosition: SnackPosition.TOP,
            title: res.ok ? 'Success'.tr : 'Ops!',
          );
        }
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: cardWidth,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + bookmark
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: item.serviceImage ?? '',
                  height: imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: imageHeight,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: imageHeight,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: toggleWishlist,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSaved ? AppColors.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.bookmark_border,
                        size: 24,
                        color: isSaved ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + price row
                  Row(
                    children: [
                      RatingStarsWidget(
                        rating: item.averageRating ?? '0.0',
                        reviews: '',
                        showReviews: false,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            item.price,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (screenWidth > 360)
                            Text(
                              item.previousPrice ?? '0',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                          text: item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      SvgPicture.asset(
                        AssetsPath.markerSvg,
                        height: 12,
                        width: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          (item.address != null && item.address!.length > 30)
                              ? '${item.address!.substring(0, 30)}...'
                              : item.address ?? '00',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isTablet ? 13 : 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Book now
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: CustomButtonWidget(
                      fontSize: 16,
                      text: 'Book Now',
                      onPressed: () => Get.toNamed(
                        AppRoutes.customStepper,
                        arguments: {'selectedService': item},
                        preventDuplicates: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
