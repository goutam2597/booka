import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_button_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services/ui/widgets/s_details_widgets/review_tile.dart';
import 'package:bookapp_customer/features/wishlist/providers/wishlist_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/routes/app_routes.dart';

class ServiceCardWidget extends StatelessWidget {
  final ServicesModel item;
  final EdgeInsetsGeometry margin;
  final Color color;
  final Color border;

  const ServiceCardWidget({
    super.key,
    required this.item,
    this.margin = const EdgeInsets.only(bottom: 16),
    this.color = Colors.white,
    this.border = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Get.toNamed(
            AppRoutes.serviceDetails,
            arguments: {'slug': item.slug, 'id': item.id},
            preventDuplicates: false,
          );
        },
        child: _buildServiceCard(context),
      ),
    );
  }

  // ────── Private: Full Card UI ──────
  Widget _buildServiceCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        color: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardImage(context),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StarRow(
                        rating:
                            double.tryParse(item.averageRating ?? '') ?? 0.0,
                      ),
                      Text(
                        '(${item.averageRating ?? '0.0'})',
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildAddressRow(),
                  const SizedBox(height: 8),
                  _buildPriceAndBookButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────── Private: Top Image with Bookmark ──────
  Widget _buildCardImage(BuildContext context) {
    final provider = context.watch<WishlistProvider>();
    final isInWishlist = provider.isInWishlist(item.id);
    Future<void> toggleWishList() async {
      if (isInWishlist) {
        final response = await context
            .read<WishlistProvider>()
            .removeByServiceId(item.id);
        if (context.mounted) {
          CustomSnackBar.show(
            context,
            response.message,
            snackPosition: SnackPosition.TOP,
            icon: response.ok ? Icons.check : Icons.error_outline,
            iconBgColor: response.ok
                ? AppColors.snackSuccess
                : AppColors.snackError,
          );
        }
      } else {
        final response = await context.read<WishlistProvider>().addByServiceId(
          item.id,
        );
        if (context.mounted) {
          CustomSnackBar.show(
            context,
            response.message,
            snackPosition: SnackPosition.TOP,
            icon: response.ok ? Icons.check : Icons.error_outline,
            iconBgColor: response.ok
                ? AppColors.snackSuccess
                : AppColors.snackError,
          );
        }
      }
    }

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: item.serviceImage ?? '',
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 160,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 160,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: InkWell(
            onTap: toggleWishList,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isInWishlist ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.bookmark_border,
                size: 24,
                color: isInWishlist ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ────── Private: Address with Icon ──────
  Widget _buildAddressRow() {
    return Row(
      children: [
        SvgPicture.asset(AssetsPath.markerSvg),
        const SizedBox(width: 4),
        Text(
          item.address != null && item.address!.length > 28
              ? '${item.address!.substring(0, 28)}...'
              : item.address ?? '',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      ],
    );
  }

  // ────── Private: Price & Button Row ──────
  Widget _buildPriceAndBookButton(BuildContext context) {
    return Row(
      children: [
        Text(
          item.price,
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 104,
          height: 44,
          child: CustomButtonWidget(
            text: 'Book Now',
            onPressed: () {
              Get.toNamed(
                AppRoutes.customStepper,
                arguments: {'selectedService': item},
              );
            },
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
