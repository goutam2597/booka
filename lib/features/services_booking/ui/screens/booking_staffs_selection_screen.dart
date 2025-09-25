import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_header_text_widget.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/staff_card_widget.dart';
import 'package:bookapp_customer/features/services_booking/providers/booking_staffs_selection_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const int kAdminFallbackStaffId = 1;

class BookingStaffsSelectionScreen extends StatelessWidget {
  final ServicesModel service;
  final ValueChanged<StaffModel> onStaffSelected;

  const BookingStaffsSelectionScreen({
    super.key,
    required this.service,
    required this.onStaffSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingStaffsSelectionProvider(service: service)..init(),
      builder: (context, _) {
        final p = context.watch<BookingStaffsSelectionProvider>();
        if (p.loading) {
          return const Scaffold(body: Center(child: CustomCPI()));
        }
        return Scaffold(
          body: _buildStaffGrid(context, p.staffs.isNotEmpty ? p.staffs : []),
        );
      },
    );
  }

  Widget _buildStaffGrid(BuildContext context, List<StaffModel> staffList) {
    const double horizontalPadding = 16;
    const double spacing = 8;
    final screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth =
        (screenWidth - horizontalPadding * 2 - spacing) / 2;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CustomHeaderTextWidget(text: 'Choose Your Staff'),
            ),
            Wrap(
              spacing: spacing,
              runSpacing: 24,
              children: staffList.map((staff) {
                return SizedBox(
                  width: itemWidth,
                  height: 260,
                  child: StaffCardWidget(
                    item: staff,
                    onSelectStaff: () => onStaffSelected(staff),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }
}
