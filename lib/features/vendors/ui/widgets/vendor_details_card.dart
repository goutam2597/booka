import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/features/common/ui/widgets/expandable_text.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_details_model.dart';
import 'package:bookapp_customer/features/vendors/ui/widgets/info_card.dart';
import 'package:bookapp_customer/features/vendors/ui/widgets/verified_badge_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Vendor details card (header + info)
class VendorDetailsCard extends StatelessWidget {
  final VendorDetailsModel details;
  const VendorDetailsCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final vendor = details.vendor;
    final photo = vendor.photo;

    final BoxDecoration boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
      image: (details.bgImg?.isNotEmpty ?? false)
          ? DecorationImage(
              alignment: Alignment.topCenter,
              image: CachedNetworkImageProvider(details.bgImg!),
              fit: BoxFit.contain,
            )
          : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: boxDecoration,
        child: Column(
          children: [
            const SizedBox(height: 28),
            SizedBox(
              width: 80,
              height: 80,
              child: ClipOval(
                child: (photo != null && photo.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: photo,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _avatarPlaceholder(),
                        errorWidget: (context, url, error) =>
                            _avatarPlaceholder(),
                      )
                    : _avatarPlaceholder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _displayName(details),
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            VerifiedBadge(isVerified: details.vendor.verified != null),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
              child: Visibility(
                visible:
                    ((details.vendorInfo?.details ?? '').trim().isNotEmpty) ||
                    ((details.vendor.details ?? '').trim().isNotEmpty),
                child: Column(
                  children: [
                    ExpandableText(
                      details.vendorInfo?.details ??
                          details.vendor.details ??
                          '',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                      trimLines: 2,
                      moreText: 'Show More'.tr,
                      lessText: 'Show Less'.tr,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            InfoCard(details: details),
          ],
        ),
      ),
    );
  }

  static Widget _avatarPlaceholder() => Container(
    color: Colors.grey.shade200,
    alignment: Alignment.center,
    child: Icon(Icons.store, color: Colors.grey.shade600),
  );

  static String _displayName(VendorDetailsModel details) {
    final viName = details.vendorInfo?.name.trim();
    if (viName != null && viName.isNotEmpty) return viName;
    final fn = details.vendor.firstName?.trim() ?? '';
    final ln = details.vendor.lastName?.trim() ?? '';
    final full = ('$fn $ln').trim();
    if (full.isNotEmpty) return full;
    final uname = details.vendor.username.trim();
    if (uname.isNotEmpty) {
      return uname[0].toUpperCase() + uname.substring(1);
    }
    return 'Vendor';
  }
}
