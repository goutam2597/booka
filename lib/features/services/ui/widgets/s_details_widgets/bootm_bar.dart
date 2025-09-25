import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/services/ui/widgets/s_details_widgets/inquiry_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services/data/models/service_details_model.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_button_widget.dart';

import '../../../../../app/routes/app_routes.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.service});
  final ServiceDetailsModel service;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 60,
            color: Colors.white,
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    final uname =
                        service.details.vendor?.username ??
                        service.admin?.username ??
                        '';
                    Get.toNamed(AppRoutes.vendorDetails, arguments: uname);
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    height: 52,
                    width: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: _VendorAvatarImage(
                          photo:
                              service.details.vendor?.photo ??
                              service.admin?.image ??
                              '',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),

                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => showInquiryDialog(service, context),
                  child: Container(
                    height: 52,
                    width: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      size: 32,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                SizedBox(width: 8),
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    height: 52,
                    child: CustomButtonWidget(
                      onPressed: () {
                        final model = ServicesModel(
                          id: service.details.id,
                          vendorId: service.details.vendor?.id ?? 0,
                          slug: service.relatedServices.first.slug,
                          name: service.details.content.name,
                          price: service.details.price.toString(),
                          previousPrice: service.details.previousPrice,
                          address: service.details.vendor?.address,
                          categoryName:
                              service.relatedServices.first.categoryName,
                          categorySlug:
                              service.relatedServices.first.categorySlug,
                          vendor: service.details.vendor,
                        );
                        Get.toNamed(
                          AppRoutes.customStepper,
                          arguments: {'selectedService': model},
                        );
                      },
                      text: isRtl ? 'Book Now'.tr : 'Book This Service'.tr,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal helper that decides whether to load a network image or an asset
/// to avoid passing local asset paths into CachedNetworkImage (which expects
/// a valid URL and would throw an error like: No host specified in URI).
class _VendorAvatarImage extends StatelessWidget {
  final String photo;
  const _VendorAvatarImage({required this.photo});

  bool get _isNetwork => photo.isNotEmpty && !photo.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: photo,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        placeholder: (ctx, url) => Image.asset(
          AssetsPath.defaultVendor,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        ),
        errorWidget: (ctx, url, error) => Image.asset(
          AssetsPath.defaultVendor,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        ),
      );
    }
    // Fallback to asset image directly
    return Image.asset(
      AssetsPath.defaultVendor,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.low,
    );
  }
}
