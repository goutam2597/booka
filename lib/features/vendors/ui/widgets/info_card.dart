import 'package:bookapp_customer/features/common/ui/widgets/contact_now_alert_dialog_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_button_widget.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_details_model.dart';
import 'package:bookapp_customer/features/vendors/ui/screens/vendor_details_screen.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final VendorDetailsModel details;
  const InfoCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final vendor = details.vendor;
    final String? createdAt = (vendor.createdAt is String)
        ? vendor.createdAt as String
        : null;
    final String phone = vendor.phone?.toString() ?? '';

    final labels = <String>[
      'Total Service',
      'Address',
      if (phone.isNotEmpty) 'Phone',
      'Email',
      if (createdAt != null) 'Member since',
    ];

    final values = <String>[
      details.totalService.toString(),
      details.vendorAddress,
      if (phone.isNotEmpty) phone,
      details.vendor.email ?? '',
      if (createdAt != null)
        (createdAt.isNotEmpty) ? createdAt.split('T').first : 'N/A',
    ];

    // Align colons with labels/values counts
    final colons = List<String>.filled(labels.length, ':');

    return Card(
      margin: EdgeInsets.zero,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: ColumnText(items: labels, isLabel: true),
                ),
                ColumnText(items: colons, isLabel: true),
                const SizedBox(width: 12),
                Expanded(flex: 8, child: ColumnText(items: values)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: SizedBox(
              height: 50,
              child: CustomButtonWidget(
                fontSize: 18,
                text: 'Contact Now',
                onPressed: () => _showContactDialog(context, details),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context, VendorDetailsModel details) {
    showDialog(
      context: context,
      builder: (context) => ContactNowAlertDialogWidget(
        vendorEmail: details.vendor.email ?? details.vendor.admin?.email ?? '',
      ),
    );
  }
}
