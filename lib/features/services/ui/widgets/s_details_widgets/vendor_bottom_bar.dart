import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services/data/models/service_details_model.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_button_widget.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import 'inquiry_dialog.dart';

class VendorBottomBar extends StatelessWidget {
  const VendorBottomBar({super.key, required this.service});
  final ServiceDetailsModel service;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 180,
          color: Colors.white,
          child: Column(
            children: [
              Card(
                elevation: 0,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 32,
                        backgroundImage: CachedNetworkImageProvider(
                          service.details.vendor?.photo ?? service.admin!.image,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.details.vendorInfo?.name ??
                                  '${service.admin!.firstName} ${service.admin!.lastName}',
                              style: AppTextStyles.headingSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.colorText,
                              ),
                            ),
                            if (service.details.vendor?.phone != null &&
                                service.details.vendor!.phone!
                                    .trim()
                                    .isNotEmpty)
                              Text(
                                'Phone: ${service.details.vendor!.phone}',
                                style: AppTextStyles.bodySmall,
                              ),
                            Text(
                              'Email: ${service.details.vendor?.email ?? service.admin!.email}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => showInquiryDialog(service, context),
                        child: Container(
                          height: 56,
                          width: 56,
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
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
                      categoryName: service.relatedServices.first.categoryName,
                      categorySlug: service.relatedServices.first.categorySlug,
                      vendor: service.details.vendor,
                    );
                    Get.toNamed(
                      AppRoutes.customStepper,
                      arguments: {'selectedService': model},
                    );
                  },
                  text: 'Book This Service',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
