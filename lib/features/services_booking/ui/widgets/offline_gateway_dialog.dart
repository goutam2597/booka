import 'dart:io';
import 'package:bookapp_customer/features/common/ui/widgets/custom_button_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_header_text_widget.dart';
import 'package:bookapp_customer/features/services_booking/providers/offline_gateway_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class OfflineGatewayDialog extends StatelessWidget {
  const OfflineGatewayDialog({
    super.key,
    required this.gatewayName,
    required this.instructions,
    this.attachmentFieldName = 'attachment',
    this.initialName,
    this.showAttachment = true,
    this.attachmentRequired = false,
  });

  final String gatewayName;
  final String instructions; // plain string
  final String attachmentFieldName;
  final String? initialName;
  final bool showAttachment;
  final bool attachmentRequired;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return ChangeNotifierProvider(
      create: (_) => OfflineGatewayProvider(initialName: initialName),
      builder: (context, _) {
        final p = context.watch<OfflineGatewayProvider>();
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(child: Text(gatewayName.tr)),
          actionsPadding: const EdgeInsets.only(bottom: 4, left: 20, right: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Form(
            key: p.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomHeaderTextWidget(text: 'Name'.tr, fontSize: 16),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: p.nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Enter your name'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name is required'.tr
                        : null,
                  ),
                  const SizedBox(height: 12),
                  CustomHeaderTextWidget(text: 'Instructions'.tr, fontSize: 16),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Text(
                      instructions.isEmpty
                          ? 'Please attach proof of payment as instructed by the vendor.'.tr
                          : instructions,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (showAttachment)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomHeaderTextWidget(
                          text: (attachmentRequired
                                  ? 'Attachment (Required)'
                                  : 'Attachment (Optional)')
                              .tr,
                          fontSize: 16,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.only(
                                    topLeft: isRtl
                                        ? const Radius.circular(0)
                                        : const Radius.circular(8),
                                    bottomLeft: isRtl
                                        ? const Radius.circular(0)
                                        : const Radius.circular(8),
                                    topRight: isRtl
                                        ? const Radius.circular(8)
                                        : const Radius.circular(0),
                                    bottomRight: isRtl
                                        ? const Radius.circular(8)
                                        : const Radius.circular(0),
                                  ),
                                  border: Border(
                                    right: BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                width: 120,
                                height: 52,
                                child: TextButton(
                                  onPressed: p.submitting ? null : p.pickImage,
                                  child: Text(
                                    p.pickedFile == null
                                        ? 'Choose File'.tr
                                        : 'Change file'.tr,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  p.pickedFile?.path
                                          .split(Platform.pathSeparator)
                                          .last ??
                                      'No file selected'.tr,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (p.attachmentError)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Attachment is required'.tr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          actions: [
            SizedBox(
              height: 52,
              child: CustomButtonWidget(
                text: 'Make Payment',
                onPressed: () => p.submit(
                  context,
                  showAttachment: showAttachment,
                  attachmentRequired: attachmentRequired,
                  attachmentFieldName: attachmentFieldName,
                ),
                fontSize: 18,
              ),
            ),
            Center(
              child: TextButton(
                onPressed: p.submitting ? null : () => Navigator.of(context).pop(),
                child: Text('Cancel'.tr),
              ),
            ),
          ],
        );
      },
    );
  }
}
