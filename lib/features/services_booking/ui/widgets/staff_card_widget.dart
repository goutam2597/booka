import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/app/text_capitalizer.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class StaffCardWidget extends StatelessWidget {
  final StaffModel item;
  final VoidCallback onSelectStaff;

  const StaffCardWidget({
    super.key,
    required this.item,
    required this.onSelectStaff,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelectStaff,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 4),

                  // ───── Avatar with shimmer ─────
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipOval(
                      child: item.image != null && item.image!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.image!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: Image.asset(
                                  AssetsPath.defaultVendor,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: Image.asset(
                                AssetsPath.defaultVendor,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      item.name.toTitleCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SelectableText(
                      item.email,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onSelectStaff,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Material(
                          borderRadius: BorderRadius.circular(6),
                          elevation: 0.1,
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Select Staff'.tr,
                              style: AppTextStyles.bodyLarge,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
