import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/text_capitalizer.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services_booking/data/available_time_recponse_model.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/booking_text_button_widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bookapp_customer/features/appointments/providers/appointments_provider.dart';
import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';

class OrderSummaryScreen extends StatelessWidget {
  final ServicesModel service;
  final StaffModel staff;
  final DateTime bookingDate;
  final AvailableTimeResponseModel bookingTime;
  final Map<String, String> billingDetails;
  final int totalAmount;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const OrderSummaryScreen({
    super.key,
    required this.service,
    required this.staff,
    required this.bookingDate,
    required this.bookingTime,
    required this.billingDetails,
    required this.totalAmount,
    required this.onBack,
    required this.onNext,
  });

  String _fmtDate(DateTime d) => d.toIso8601String().split('T').first;

  @override
  Widget build(BuildContext context) {
    // Use the formatted price from ServicesModel (includes currency symbol)
    final String displayPrice = (service.price.isNotEmpty
        ? service.price
        : totalAmount.toString());
    final name = (billingDetails['fullName'] ?? billingDetails['name'] ?? '')
        .trim();
    final email = (billingDetails['email'] ?? '').trim();
    final phone =
        (billingDetails['phone'] ?? billingDetails['phoneNumber'] ?? '').trim();
    final persons = billingDetails['persons'] ?? '1';
    final address = billingDetails['address'] ?? '';
    final country = billingDetails['country'] ?? '';

    final vendorLabel = () {
      try {
        final fromProvider = context.select<AppointmentsProvider, String>(
          (prov) => prov.vendorNameById(service.vendorId.toString()),
        );
        if (fromProvider.toLowerCase().startsWith('vendor #')) {
          final v = service.vendor;
          if (v != null) {
            final label = v.labelPreferUsername.trim();
            if (label.isNotEmpty) return label;
          }
          final adminUser = (service.admin?.username ?? '').trim();
          if (adminUser.isNotEmpty) return adminUser;
        }
        return fromProvider;
      } catch (_) {
        final v = service.vendor;
        if (v != null) {
          final label = v.labelPreferUsername.trim();
          if (label.isNotEmpty) return label;
        }
        final adminUser = (service.admin?.username ?? '').trim();
        if (adminUser.isNotEmpty) return adminUser;
        return 'Admin';
      }
    }();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.white,
                elevation: 0.3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Order Summary'.tr,
                          style: AppTextStyles.headingMedium,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Divider(),
                      const SizedBox(height: 12),
                      Text(
                        '${'Service'.tr} ${'Information'.tr}',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.serviceDetails,
                            arguments: {'slug': service.slug, 'id': service.id},
                          );
                        },
                        child: _kv(
                          'Service Title',
                          service.name,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      _kv('Service Provider', vendorLabel.toTitleCase()),
                      _kv('Staff Name', staff.name),
                      _kv('Appointment Date', _fmtDate(bookingDate)),
                      _kv(
                        'Appointment Time',
                        '${bookingTime.startTime} - ${bookingTime.endTime}',
                      ),
                      _kv('Number of Persons', persons),
                      const Divider(height: 18),
                      Text(
                        '${'User'.tr} ${'Information'.tr}',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      _kv('Name', name.isEmpty ? '-' : name),
                      _kv('Email', email.isEmpty ? '-' : email),
                      _kv('Phone', phone.isEmpty ? '-' : phone),
                      _kv('Country', country.isEmpty ? '-' : country),
                      _kv('Address', address.isEmpty ? '-' : address),
                      const Divider(height: 18),
                      SizedBox(height: 8),
                      _kv('Payable Amount', displayPrice),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: BookingTextButtonWidget(
                      onTap: onBack,
                      text: 'Prev Step',
                      icon: Icons.arrow_back,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      onPressed: onNext,
                      child: Text('Make Payment'.tr),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _kv(String content, String data, {Color color = Colors.black54}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                content.tr,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                data,
                style: AppTextStyles.bodyLargeGrey.copyWith(color: color),
              ),
            ),
          ],
        ),
      );
}
