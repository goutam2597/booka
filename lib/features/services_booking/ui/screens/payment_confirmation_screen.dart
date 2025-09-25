import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/text_capitalizer.dart';
import 'package:flutter/material.dart';
import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/features/common/ui/widgets/information_card_widget.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/booking_text_button_widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bookapp_customer/features/appointments/providers/appointments_provider.dart';

import '../../../../app/routes/app_routes.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final VoidCallback onBackToHome;
  final ServicesModel services;
  final StaffModel? selectedStaff;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final String? selectedPaymentMethod;
  final String? bookingId;

  const PaymentConfirmationScreen({
    super.key,
    required this.onBackToHome,
    required this.services,
    this.selectedStaff,
    this.selectedDate,
    this.selectedTimeSlot,
    this.selectedPaymentMethod,
    this.bookingId,
  });

  String _fmtDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  // Legacy fallback if provider is missing; prefer provider path below.
  String _fallbackVendorName() {
    final vendor = services.vendor;
    if (vendor != null) {
      final label = vendor.labelPreferUsername.trim();
      if (label.isNotEmpty) return label;
    }
    final admin = services.admin;
    final first = (admin?.firstName ?? '').trim();
    final last = (admin?.lastName ?? '').trim();
    final full = [first, last].where((p) => p.isNotEmpty).join(' ').trim();
    if (full.isNotEmpty) return full;
    final user = (admin?.username ?? '').trim();
    if (user.isNotEmpty) return user;
    return 'Admin';
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = selectedDate != null
        ? _fmtDate(selectedDate!)
        : "-";

    // Resolve vendor label via AppointmentsProvider reactively
    final vendorLabel = () {
      try {
        final fromProvider = context.select<AppointmentsProvider, String>(
          (prov) => prov.vendorNameById(services.vendorId.toString()),
        );
        if (fromProvider.toLowerCase().startsWith('vendor #')) {
          return _fallbackVendorName();
        }
        return fromProvider;
      } catch (_) {
        return _fallbackVendorName();
      }
    }();

    final bookingDetails = <MapEntry<String, String>>[
      MapEntry('Service Title', services.name),
      MapEntry('Booking Date', formattedDate),
      MapEntry('Appointment Date', formattedDate),
      MapEntry('Appointment Time', selectedTimeSlot ?? "-"),
      MapEntry('Staff Name', selectedStaff?.name.toTitleCase() ?? "-"),
      MapEntry('Vendor', vendorLabel.toTitleCase()),
      MapEntry('Paid Amount', services.price),
      MapEntry('Payment Method', selectedPaymentMethod?.toTitleCase() ?? '-'),
      const MapEntry('Payment Status', 'Completed'),
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildConfirmationHeader(context),
                  const SizedBox(height: 24),

                  // Booking details card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InformationCardWidget(
                      tappableIndex: 0,
                      onTap: () {
                        Get.offAllNamed(
                          AppRoutes.serviceDetails,
                          arguments: {'slug': services.slug, 'id': services.id},
                        );
                      },
                      cardTitle: 'Booking details',
                      infoEntries: bookingDetails,
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Back to Home button
                  BookingTextButtonWidget(
                    onTap: () {
                      // Pop everything and go to home
                      Get.offAllNamed(AppRoutes.bottomNav);
                    },
                    text: 'Back to Home',
                    icon: Icons.arrow_back,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  /// Confirmation header with dynamic category and status text.
  Widget _buildConfirmationHeader(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.verified, size: 80, color: AppColors.primaryColor),
        const SizedBox(height: 8),
        Text(
          'Thank you'.tr,
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              radius: 16,
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (services.category != null) {
                  Get.offAllNamed(
                    AppRoutes.category,
                    arguments: services.category!,
                  );
                } else {}
              },
              child: _headerText(
                '( ${services.categoryName} )',
                bold: true,
                color: AppColors.primaryColor,
              ),
            ),
            _headerText('Service is Booked'),
          ],
        ),
        const SizedBox(height: 4),
        if ((bookingId ?? '').isNotEmpty)
          Text(
            '${'Booking ID'.tr}: ${bookingId!}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.colorText,
            ),
          ),
      ],
    );
  }

  /// Utility for styled header text
  Widget _headerText(
    String text, {
    bool bold = false,
    Color color = const Color(0xFF757575),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text.tr,
        style: TextStyle(
          fontSize: 16,
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          color: color,
        ),
      ),
    );
  }
}
