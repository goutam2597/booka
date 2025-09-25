import 'package:bookapp_customer/features/appointments/providers/appointment_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bookapp_customer/app/app_text_styles.dart';
import 'package:bookapp_customer/app/order_status_color.dart';
import 'package:bookapp_customer/app/text_capitalizer.dart';
import 'package:bookapp_customer/features/appointments/models/appointment_details_model.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/information_card_widget.dart';
import '../../../../app/routes/app_routes.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final int appointmentId;
  const AppointmentDetailsScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  bool _kickoffScheduled = false;

  @override
  void initState() {
    super.initState();

    // Defer initial fetch to the next frame to avoid notifying during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final store = context.read<AppointmentDetailsProvider>();
      final id = widget.appointmentId;

      final hasData = store.get(id) != null;
      final hasError = store.error(id) != null;
      final isLoading = store.loading(id);

      if (!isLoading && !hasData && !hasError) {
        store.fetch(id);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Optional safety: ensure we schedule once in case initState path was skipped.
    if (!_kickoffScheduled) {
      _kickoffScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final store = context.read<AppointmentDetailsProvider>();
        final id = widget.appointmentId;
        if (!store.loading(id) &&
            store.get(id) == null &&
            store.error(id) == null) {
          store.fetch(id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppointmentDetailsProvider>();
    final id = widget.appointmentId;

    final loading = store.loading(id);
    final error = store.error(id);
    final data = store.get(id);

    final isInitial = (data == null && error == null);

    return Scaffold(
      body: Builder(
        builder: (_) {
          // Handle pre-fetch and active-loading states
          if (loading || isInitial) {
            // Keep it scrollable so RefreshIndicator can still work if you want to allow pull-to-refresh
            return const Center(child: CustomCPI());
          }

          if (error != null && data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      context.read<AppointmentDetailsProvider>().refresh(id);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Safe to unwrap now
          final AppointmentDetailsModel appt = data!;

          return Column(
            children: [
              const CustomAppBar(title: 'Appointment details'),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      context.read<AppointmentDetailsProvider>().refresh(id),
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
                                            "Booking ID: ${appt.orderNumber} ",
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                "[${appt.orderStatus.toTitleCase()}]",
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                                  color: getOrderStatusColor(
                                                    appt.orderStatus,
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
                                          TextSpan(text: appt.bookingDate),
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
                                  'slug': appt.serviceSlug,
                                  'id': appt.serviceId,
                                },
                              );
                            },
                            cardTitle: 'Booking details',
                            infoEntries: [
                              MapEntry('Service Title', appt.serviceName),
                              MapEntry('Service Address', appt.serviceAddress),
                              MapEntry('Appointment Date', appt.bookingDate),
                              MapEntry(
                                'Appointment Time',
                                '${appt.startDate} - ${appt.endDate}',
                              ),
                              MapEntry('Person', appt.maxPerson),
                              MapEntry('Staff Name', appt.staffName),
                            ],
                          ),
                          const SizedBox(height: 16),
                          InformationCardWidget(
                            cardTitle: 'Payment Information',
                            infoEntries: [
                              MapEntry('Paid Amount', '\$${appt.customerPaid}'),
                              MapEntry(
                                'Payment Method',
                                appt.paymentMethod.toTitleCase(),
                              ),
                              MapEntry(
                                'Payment Status',
                                appt.paymentStatus.toUpperCase(),
                              ),
                              MapEntry(
                                'Booking Status',
                                appt.orderStatus.toUpperCase(),
                              ),
                            ],
                            customTextColors: {
                              'Payment Status': getOrderStatusColor(
                                appt.paymentStatus,
                              ),
                              'Booking Status': getOrderStatusColor(
                                appt.orderStatus,
                              ),
                            },
                          ),
                          const SizedBox(height: 16),
                          InformationCardWidget(
                            cardTitle: 'Billing Address',
                            infoEntries: [
                              MapEntry('Name', appt.customerName),
                              MapEntry('Email Address', appt.customerEmail),
                              MapEntry('Phone', appt.customerPhone),
                              MapEntry('Country', appt.customerCountry),
                              MapEntry('Address', appt.customerAddress),
                            ],
                          ),
                          const SizedBox(height: 16),
                          InformationCardWidget(
                            cardTitle: 'Vendor Details',
                            infoEntries: [
                              MapEntry(
                                'Name',
                                appt.vendorName ?? appt.adminName ?? 'Admin',
                              ),
                              if (appt.vendorEmail.isNotEmpty)
                                MapEntry('Email Address', appt.vendorEmail),
                              if (appt.vendorPhone.isNotEmpty)
                                MapEntry('Phone', appt.vendorPhone),
                              if (appt.vendorCountry.isNotEmpty)
                                MapEntry('Country', appt.vendorCountry),
                              if (appt.vendorAddress.isNotEmpty)
                                MapEntry('Address', appt.vendorAddress),
                            ],
                          ),
                        ],
                      ),
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
}
