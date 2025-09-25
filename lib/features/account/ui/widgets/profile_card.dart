import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/auth/providers/auth_provider.dart';
import 'package:bookapp_customer/app/routes/app_routes.dart';
import 'package:bookapp_customer/features/account/models/dashboard_model.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ProfileCard extends StatelessWidget {
  final DashboardModel accountData;

  const ProfileCard({super.key, required this.accountData});

  @override
  Widget build(BuildContext context) {
    final v = context.select<AuthProvider, int>((a) => a.avatarVersion);
    final url = (accountData.userPhoto ?? '').isNotEmpty
        ? '${accountData.userPhoto}?v=$v'
        : '';

    return Card(
      elevation: 0.5,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: url,
                height: 48,
                width: 48,
                fit: BoxFit.fill,
                errorWidget: (_, _, _) => Container(
                  height: 48,
                  width: 48,
                  color: Colors.grey,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                placeholder: (_, _) => Container(
                  height: 48,
                  width: 48,
                  color: Colors.grey,
                  child: const Center(child: CustomCPI()),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: accountData.userName.isEmpty,
                    replacement: Text(
                      accountData.userName.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(
                      'Username'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Text(
                    'Customer Account'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Get.toNamed(AppRoutes.editProfile);
              },
              child: Container(
                height: 44,
                width: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  AssetsPath.userEdit,
                  height: 24,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
