import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/features/services/ui/widgets/star_rating_widget.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_model.dart';
import 'package:bookapp_customer/features/vendors/providers/vendor_details_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/routes/app_routes.dart';

class VendorsCardWidget extends StatelessWidget {
  final VendorModel vendor;
  final bool showVisitStore;
  final bool showRating;

  const VendorsCardWidget({
    super.key,
    required this.vendor,
    this.showVisitStore = true,
    this.showRating = false,
  });

  @override
  Widget build(BuildContext context) {
    final uname = vendor.username.trim();
    final name = uname.isNotEmpty
        ? uname[0].toUpperCase() + uname.substring(1)
        : '';
    final email = vendor.email ?? '';
    final photo = vendor.photo ?? '';
    final rating = vendor.avgRating;

    // kick off details fetch lazily once (if not cached)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final provider = context.read<VendorDetailsProvider>();
      final st = provider.stateFor(uname);
      if (!st.loading && st.data == null) {
        provider.fetch(uname);
      }
    });

    final state = context.watch<VendorDetailsProvider>().stateFor(uname);

    void goToDetails() {
      Get.toNamed(AppRoutes.vendorDetails, arguments: uname);
    }

    Widget buildServiceQty() {
      // Loading & no cached data yet
      if (state.loading && state.data == null) {
        return Text(
          '0'
          '${'Available Services'.tr}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        );
      }
      // Error & no cached data
      if (state.error != null && state.data == null) {
        return InkWell(
          onTap: () => context.read<VendorDetailsProvider>().fetch(
            uname,
            forceRefresh: true,
          ),
          child: Text(
            'Services unavailable • Retry',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.red.shade400, fontSize: 16),
          ),
        );
      }
      // Data present (or stale data with new loading)
      final count = state.data?.services.length ?? 0;
      return Text(
        '$count ${"Services Available".tr}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: goToDetails,
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Container(
              width: 240,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ───── Avatar with shimmer while loading ─────
                  SizedBox(
                    width: 88,
                    height: 88,
                    child: ClipOval(
                      child: photo.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: photo,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey.shade600,
                                  size: 28,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.store,
                                color: Colors.grey.shade600,
                                size: 28,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      name.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.titleColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SelectableText(
                            email,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(thickness: 1, color: Colors.grey.shade300),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: buildServiceQty(),
                  ),

                  const SizedBox(height: 8),
                  if (showRating)
                    RatingStarsWidget(
                      rating: rating,
                      reviews: '',
                      showStar: false,
                      showRating: true,
                      showReviews: false,
                      showRatingInP: true,
                      showRatingInNp: false,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showVisitStore)
          Positioned(
            bottom: 16,
            left: 56,
            right: 56,
            child: GestureDetector(
              onTap: goToDetails,
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Text(
                    'Visit Store',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
