import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_snack_bar_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_icon_button_widgets.dart';
import 'package:bookapp_customer/network_service/core/email_network_service.dart';
import 'package:bookapp_customer/features/services/data/models/service_details_model.dart';
import 'package:get/get.dart';

void showInquiryDialog(ServiceDetailsModel service, BuildContext context) {
  final vendorId =
      service.details.vendor?.id.toString() ?? service.admin?.id.toString();
  final serviceId = service.details.id.toString();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool submitting = false;

  String? requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(v.trim()) ? null : 'Enter a valid email';
  }

  Future<void> submit(StateSetter setStateDialog) async {
    if (!formKey.currentState!.validate()) return;
    if (vendorId == null || serviceId.isEmpty) {
      CustomSnackBar.show(context, 'Missing Vendor/Service ID');
      return;
    }

    setStateDialog(() => submitting = true);

    final result = await EmailNetworkService.sendInquiry(
      vendorId: vendorId,
      serviceId: serviceId,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      message: messageController.text.trim(),
    );

    if (!context.mounted) return;
    setStateDialog(() => submitting = false);

    if (result.success) {
      Navigator.pop(context);
      CustomSnackBar.show(
        context,
        result.message.isNotEmpty ? result.message : 'Message sent successfully!',
      );
    } else {
      CustomSnackBar.show(context, result.message);
    }
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Service Inquiry'.tr,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, _) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curved),
              child: Center(
                child: Dialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.white,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Service Inquiry'.tr, style: AppTextStyles.headingLarge),
                                CustomIconButtonWidget(
                                  assetPath: AssetsPath.cancelSvg,
                                  onTap: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage: CachedNetworkImageProvider(
                                service.details.vendor?.photo ?? service.admin!.image,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              service.details.vendorInfo?.name ??
                                  '${service.admin!.firstName} ${service.admin!.lastName}',
                              style: AppTextStyles.headingMedium,
                            ),
                            if (service.details.vendor?.phone != null &&
                                service.details.vendor!.phone!.trim().isNotEmpty)
                              Text('${service.details.vendor!.phone}', style: AppTextStyles.bodySmall),
                            Text(
                              service.details.vendor?.email ?? service.admin!.email,
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: firstNameController,
                              validator: requiredValidator,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(hintText: 'First Name'.tr),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: lastNameController,
                              validator: requiredValidator,
                              textInputAction: TextInputAction.next,
                              decoration:  InputDecoration(hintText: 'Last Name'.tr),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: emailController,
                              validator: emailValidator,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(hintText: 'Email Address'.tr),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: messageController,
                              validator: requiredValidator,
                              maxLines: 5,
                              decoration: InputDecoration(hintText: 'Write Your Message'.tr),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 52,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: submitting ? null : () => submit(setStateDialog),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  submitting ? 'Sending…' : 'Send'.tr,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            if (submitting) ...[
                              const SizedBox(height: 12),
                              const CustomCPI(),
                            ],
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
