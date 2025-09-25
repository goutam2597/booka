import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/app/providers/locale_provider.dart';
import 'package:bookapp_customer/app/routes/app_routes.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_icon_button_widgets.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/dropdown_alert_dialog.dart';
import 'package:bookapp_customer/features/common/ui/widgets/network_app_logo.dart';
import 'package:bookapp_customer/features/home/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required this.mounted,
    required this.context,
    required this.logoWidth,
    required this.hasUnread,
  });

  final bool mounted;
  final BuildContext context;
  final double logoWidth;
  final bool hasUnread;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NetworkAppLogo(width: logoWidth, height: 24),
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomIconButtonWidget(
                      assetPath: AssetsPath.notificationIconSvg,
                      onTap: () {
                        Get.toNamed(AppRoutes.notifications);
                        if (mounted) {
                          context.read<NotificationProvider>().refresh();
                        }
                      },
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                CustomIconButtonWidget(
                  assetPath: AssetsPath.languageSvg,
                  onTap: () async {
                    final rootContext = context;
                    final lp = rootContext.read<LocaleProvider>();
                    final currentCode = lp.locale.languageCode;
                    final languages = lp.languages;
                    final names = languages.isNotEmpty
                        ? languages.map((l) => l.name).toList(growable: false)
                        : <String>['English', 'Arabic'];
                    String initialName;
                    if (languages.isNotEmpty) {
                      initialName = (languages.firstWhere(
                        (l) =>
                            l.code.toLowerCase() == currentCode.toLowerCase(),
                        orElse: () => languages.first,
                      )).name;
                    } else {
                      initialName = currentCode.toLowerCase() == 'ar'
                          ? 'Arabic'
                          : 'English';
                    }

                    String? nextCode;
                    String? nextName;

                    await showDialog(
                      context: rootContext,
                      builder: (dialogCtx) => DropdownAlertDialog(
                        dialogType: DialogType.dropdown,
                        drpDownTitle: 'Language'.tr,
                        title: 'Language'.tr,
                        btnTitle: 'Save Changes'.tr,
                        items: names,
                        initialValue: initialName,
                        onConfirm: (selectedValue) {
                          final bool hasChoice =
                              selectedValue is String &&
                              selectedValue.isNotEmpty;
                          if (!hasChoice) {
                            nextCode = 'en';
                            nextName = 'English';
                            return;
                          }
                          nextName = selectedValue;
                          if (languages.isNotEmpty) {
                            final match = languages.firstWhere(
                              (l) => l.name == selectedValue,
                              orElse: () => languages.first,
                            );
                            nextCode = match.code;
                          } else {
                            nextCode = selectedValue.toLowerCase() == 'arabic'
                                ? 'ar'
                                : 'en';
                          }
                        },
                      ),
                    );

                    if (nextCode != null && context.mounted) {
                      await rootContext.read<LocaleProvider>().setLocale(
                        Locale(nextCode!),
                      );
                      if (context.mounted) {
                        CustomSnackBar.show(
                          rootContext,
                          '${"language changed to".tr} ${nextName ?? 'English'}',
                          snackPosition: SnackPosition.TOP,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
