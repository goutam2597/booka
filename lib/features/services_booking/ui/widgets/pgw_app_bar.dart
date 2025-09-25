import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_icon_button_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';

class PGWAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const PGWAppBar({super.key, required this.title});

  @override
  State<PGWAppBar> createState() => _PGWAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _PGWAppBarState extends State<PGWAppBar> {
  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurStyle: BlurStyle.solid,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        forceMaterialTransparency: true,
        foregroundColor: Colors.transparent,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              widget.title.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Align(
              alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
              child: CustomIconButtonWidget(
                assetPath: AssetsPath.backIconSvg,
                flipHorizontally: isRtl,

                onTap: () {
                  final rootNav = Navigator.of(context, rootNavigator: true);
                  if (rootNav.canPop()) {
                    rootNav.pop();
                    return;
                  }

                  final localNav = Navigator.of(context);
                  if (localNav.canPop()) {
                    localNav.pop();
                    return;
                  }
                  Get.offAllNamed(AppRoutes.bottomNav);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
