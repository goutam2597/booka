
import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/routes/app_routes.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:bookapp_customer/features/services/ui/widgets/star_rating_widget.dart';
import 'package:bookapp_customer/features/wishlist/data/models/wishlist_model.dart';
import 'package:bookapp_customer/features/wishlist/providers/wishlist_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class WishlistCard extends StatelessWidget {
  const WishlistCard({
    super.key,
    required this.wishlistData,
    required this.scaffoldContext,
  });
  final WishlistModel wishlistData;
  final BuildContext scaffoldContext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SizedBox(
        height: 104,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.toNamed(
              AppRoutes.serviceDetails,
              arguments: {
                'slug': wishlistData.slug,
                'id': wishlistData.serviceId,
              },
            );
          },
          child: Card(
            color: Colors.white,
            elevation: 0.3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 9,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: wishlistData.serviceImage,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            placeholder: (c, _) => Container(
                              height: 80,
                              width: 80,
                              alignment: Alignment.center,
                              child: const CustomCPI(),
                            ),
                            errorWidget: (c, _, _) => Container(
                              height: 80,
                              width: 80,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 170,
                              child: Text(
                                wishlistData.name,
                                style: AppTextStyles.bodyLarge,
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                RatingStarsWidget(
                                  reviews: '',
                                  showReviews: false,
                                  rating: wishlistData.averageRating ?? '0.0',
                                ),
                                const SizedBox(width: 24),
                                Text(
                                  '\$${wishlistData.price}',
                                  style: AppTextStyles.headingMedium.copyWith(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: CircleAvatar(
                      radius: 24,
                      child: IconButton(
                        onPressed: () async {
                          final res = await context
                              .read<WishlistProvider>()
                              .removeByServiceId(wishlistData.serviceId);

                          if (context.mounted) {
                            CustomSnackBar.show(scaffoldContext, res.message);
                          }
                        },
                        icon: const Icon(Icons.delete_rounded, size: 32),
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
