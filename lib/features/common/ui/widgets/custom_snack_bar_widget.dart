import 'package:bookapp_customer/app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  CustomSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    bool showTitle = false,
    String title = 'Success',
    SnackPosition snackPosition = SnackPosition.TOP,
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    double borderRadius = 8,
    Color? iconBgColor = AppColors.snackSuccess,
    double margin = 0,
    IconData? icon = Icons.check,
    bool floating = false,
  }) {
    if (showTitle) {
      Get.snackbar(
        title.tr,
        message.tr,
        snackPosition: snackPosition,
        backgroundColor: backgroundColor,
        colorText: textColor,
        borderRadius: borderRadius,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        duration: duration,
        icon: Icon(icon, color: Colors.white),
        mainButton: TextButton(
          onPressed: () => Get.closeAllSnackbars(),
          child: const Icon(Icons.close, color: Colors.white),
        ),
      );
      return;
    }

    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    Get.rawSnackbar(
      snackPosition: snackPosition,
      backgroundColor: Colors.transparent,
      borderRadius: borderRadius,
      margin: floating
          ? const EdgeInsets.fromLTRB(0, kToolbarHeight, 0, 0)
          : const EdgeInsets.only(top: kToolbarHeight - 14),
      duration: duration,
      messageText: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isRtl ? 0 : 8),
                    bottomLeft: Radius.circular(isRtl ? 0 : 8),
                    topRight: Radius.circular(isRtl ? 8 : 0),
                    bottomRight: Radius.circular(isRtl ? 8 : 0),
                  ),
                ),
                child: Center(child: Icon(icon, color: Colors.white, size: 24)),
              ),

              const SizedBox(width: 4),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: isRtl ? 4 : 0,
                    left: isRtl ? 0 : 4,
                    top: 14,
                    bottom: 14,
                  ),
                  child: Text(
                    message.tr,
                    maxLines: 3,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,

                      fontWeight: FontWeight.w500,
                    ),
                    softWrap: true,
                  ),
                ),
              ),

              // Close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: GestureDetector(
                    onTap: () => Get.closeAllSnackbars(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
