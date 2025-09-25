import 'package:bookapp_customer/features/home/data/models/notification_model.dart';
import 'package:bookapp_customer/features/vendors/models/vendor_details_model.dart';
import 'package:bookapp_customer/network_service/core/vendor_network_service.dart';
import 'package:flutter/material.dart';

import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/order_status_color.dart';
import 'package:bookapp_customer/app/text_capitalizer.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/information_card_widget.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';

class NotificationDetails extends StatelessWidget {
  final NotificationModel notification;
  const NotificationDetails({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final data = notification.data;
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(title: 'Appointment details'),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        elevation: 0.5,
                        margin: const EdgeInsets.only(
                          bottom: 12,
                          left: 2,
                          right: 2,
                        ),
                        color: Colors.grey.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text:
                                      "Booking ID ${notification.data?.orderNumber}",
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          "[${data?.orderStatus.toTitleCase()}]",
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: getOrderStatusColor(
                                          data?.orderStatus ?? '',
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text.rich(
                                TextSpan(
                                  style: AppTextStyles.bodyLargeGrey,
                                  text: 'Booking Date'.tr,
                                  children: [
                                    TextSpan(text: ' : '),
                                    TextSpan(text: data?.bookingDate ?? ''),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InformationCardWidget(
                      tappableIndex: 0,
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.serviceDetails,
                          arguments: {
                            'slug': data?.serviceSlug ?? '',
                            'id': data?.serviceId ?? 0,
                          },
                        );
                      },
                      cardTitle: 'Booking details',
                      infoEntries: [
                        MapEntry('Service Title', data?.serviceTitle ?? ''),
                        MapEntry('Appointment Date', data?.bookingDate ?? ''),
                        MapEntry(
                          'Appointment Time',
                          '${data?.startTime} - ${data?.endTime}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    InformationCardWidget(
                      cardTitle: 'Payment Information',
                      infoEntries: [
                        MapEntry('Paid Amount', data?.customerPaid ?? ''),
                        MapEntry(
                          'Payment Method',
                          data?.paymentMethod.toTitleCase() ?? '',
                        ),
                        MapEntry(
                          'Payment Status',
                          data?.paymentStatus.toUpperCase() ?? '',
                        ),
                        MapEntry(
                          'Booking Status',
                          data?.orderStatus.toUpperCase() ?? '',
                        ),
                      ],
                      customTextColors: {
                        'Payment Status': getOrderStatusColor(
                          data?.paymentStatus ?? '',
                        ),
                        'Booking Status': getOrderStatusColor(
                          data?.orderStatus ?? '',
                        ),
                      },
                    ),
                    const SizedBox(height: 16),
                    InformationCardWidget(
                      cardTitle: 'Billing Address',
                      infoEntries: [
                        MapEntry('Name', data?.customerName ?? ''),
                        MapEntry('Email Address', data?.customerEmail ?? ''),
                        MapEntry('Phone', data?.customerPhone ?? ''),
                        MapEntry('Country', data?.customerCountry ?? ''),
                        MapEntry('Address', data?.customerAddress ?? ''),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if ((data?.vendorId ?? 0) > 0)
                      FutureBuilder<VendorDetailsModel>(
                        future: VendorNetworkService.getVendorDetailsById(
                          data!.vendorId!,
                        ),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          }
                          if (!snap.hasData) return const SizedBox.shrink();
                          final vd = snap.data!;
                          final name = (() {
                            final n = vd.vendorInfo?.name.trim();
                            if (n != null && n.isNotEmpty) return n;
                            final fn = vd.vendor.firstName?.trim() ?? '';
                            final ln = vd.vendor.lastName?.trim() ?? '';
                            final full = ('$fn $ln').trim();
                            if (full.isNotEmpty) return full;
                            final u = vd.vendor.username.trim();
                            return u.isNotEmpty
                                ? u[0].toUpperCase() + u.substring(1)
                                : 'Vendor';
                          })();
                          final email = vd.vendor.email ?? '';
                          final phone = vd.vendor.phone ?? '';
                          final country =
                              vd.vendorInfo?.country ?? vd.vendor.country;
                          final address =
                              vd.vendorInfo?.address ?? vd.vendor.address;

                          final entries = <MapEntry<String, String>>[
                            MapEntry('Name', name),
                          ];
                          if (email.isNotEmpty) {
                            entries.add(MapEntry('Email Address', email));
                          }
                          if (phone.isNotEmpty) {
                            entries.add(MapEntry('Phone', phone));
                          }
                          if (country.isNotEmpty) {
                            entries.add(MapEntry('Country', country));
                          }
                          if (address.isNotEmpty) {
                            entries.add(MapEntry('Address', address));
                          }

                          return InformationCardWidget(
                            cardTitle: 'Vendor Details',
                            infoEntries: entries,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
