import 'package:flutter/material.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_icon_button_widgets.dart';
import 'package:bookapp_customer/utils/navigation_helper.dart';

class DetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return AppBar(
      automaticallyImplyLeading: false,
      title: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              'Service Details',
              style: AppTextStyles.headingSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.titleColor,
              ),
            ),
          ),
          Align(
            alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
            child: CustomIconButtonWidget(
              assetPath: AssetsPath.backIconSvg,
              flipHorizontally: isRtl,
              onTap: () => NavigationHelper.safeBack(context),
            ),
          ),
        ],
      ),
    );
  }
}
