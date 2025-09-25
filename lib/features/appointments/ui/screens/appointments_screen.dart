import 'package:bookapp_customer/features/common/ui/widgets/network_app_logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/app/order_status_color.dart';
import 'package:bookapp_customer/app/text_capitalizer.dart';

import 'package:bookapp_customer/features/appointments/models/appointment_model.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_icon_button_widgets.dart';
import 'package:bookapp_customer/features/home/providers/notification_provider.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../providers/appointments_provider.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  final List<String> languages = const ['English', 'Arabic'];

  @override
  Widget build(BuildContext context) {
    final hasUnread = context.select<NotificationProvider, bool>(
      (p) => p.hasUnread,
    );
    return Scaffold(
      appBar: _buildAppBar(context, hasUnread),
      body: Consumer<AppointmentsProvider>(
        builder: (context, prov, _) {
          // Loading vendors (initial)
          if (prov.loadingVendors && prov.vendors.isEmpty) {
            return const Center(child: CustomCPI());
          }

          // Error state (show refresh even on error/empty)
          if (prov.errorMessage != null &&
              prov.vendors.isEmpty &&
              prov.appointments.isEmpty) {
            return RefreshIndicator(
              backgroundColor: Colors.white,
              color: AppColors.primaryColor,
              notificationPredicate: (_) => true,
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              onRefresh: () async {
                await prov.refreshVendors();
                await prov.refreshAppointments();
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Material(
                              borderRadius: BorderRadius.circular(12),
                              elevation: 0.1,
                              child: Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Appointments'.tr,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Center(
                              child: Text(
                                prov.errorMessage!,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          // Loading appointments (initial)
          if (prov.loadingAppointments && prov.appointments.isEmpty) {
            return const Center(child: CustomCPI());
          }

          if (prov.appointments.isEmpty) {
            return RefreshIndicator(
              backgroundColor: Colors.white,
              color: AppColors.primaryColor,
              notificationPredicate: (_) => true,
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              onRefresh: () async {
                await prov.refreshVendors();
                await prov.refreshAppointments();
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Material(
                              borderRadius: BorderRadius.circular(12),
                              elevation: 0.1,
                              child: Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Appointments'.tr,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Center(
                              child: Text('NO APPOINTMENTS FOUND'.tr),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          final appointments = prov.appointments;

          return Column(
            children: [
              const SizedBox(height: 16),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  elevation: 0.1,
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Appointments'.tr,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RefreshIndicator(
                    backgroundColor: Colors.white,
                    color: AppColors.primaryColor,
                    notificationPredicate: (_) => true,
                    triggerMode: RefreshIndicatorTriggerMode.anywhere,
                    onRefresh: () async {
                      await prov.refreshVendors();
                      await prov.refreshAppointments();
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final item = appointments[index];
                        return _AppointmentTile(item: item);
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool hasUnread) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NetworkAppLogo(width: 120, height: 24),
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomIconButtonWidget(
                      assetPath: AssetsPath.notificationIconSvg,
                      onTap: () {
                        Get.toNamed(AppRoutes.notifications);
                        context.read<NotificationProvider>().refresh();
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.item});
  final AppointmentModel item;

  @override
  Widget build(BuildContext context) {
    final prov = context.read<AppointmentsProvider>();
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Get.toNamed(AppRoutes.appointmentDetails, arguments: item.id);
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0.3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${"By".tr} : ', style: AppTextStyles.bodyLargeGrey),
                      Text(
                        prov.vendorNameById(item.vendorId).toTitleCase(),
                        style: AppTextStyles.bodyLarge,
                      ),
                      _vDivider(),
                      Text(
                        "${"Booking Date".tr} : ",
                        style: AppTextStyles.bodyLargeGrey,
                      ),
                      Text(
                        item.bookingDate,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Time: ", style: AppTextStyles.bodyLargeGrey),
                      Text(
                        "${item.startDate} – ${item.endDate}",
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                  _vDivider(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getOrderStatusColor(item.orderStatus),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.orderStatus.tr.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vDivider() => SizedBox(
    height: 16,
    child: VerticalDivider(
      thickness: 1.5,
      color: Colors.grey.shade600,
      width: 10,
    ),
  );
}
