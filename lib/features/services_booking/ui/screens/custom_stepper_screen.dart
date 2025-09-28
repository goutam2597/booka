import 'package:flutter/material.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_app_bar.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services_booking/ui/screens/billing_screen.dart';
import 'package:bookapp_customer/features/services_booking/ui/screens/booking_login_screen.dart';
import 'package:bookapp_customer/features/services_booking/ui/screens/booking_staffs_selection_screen.dart';
import 'package:bookapp_customer/features/services_booking/ui/screens/date_n_time_screen.dart';
import 'package:bookapp_customer/features/services_booking/ui/screens/payment_confirmation_screen.dart';
import 'package:bookapp_customer/features/services_booking/ui/screens/order_summary_screen.dart';
import 'package:bookapp_customer/features/services_booking/ui/screens/payment_screen.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/custom_stepper_widget.dart';
import 'package:bookapp_customer/network_service/core/auth_network_service.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_stepper_provider.dart';

import '../../../../app/routes/app_routes.dart';

class CustomStepperScreen extends StatelessWidget {
  final ServicesModel selectedService;
  const CustomStepperScreen({super.key, required this.selectedService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingStepperProvider(selectedService: selectedService),
      child: Consumer<BookingStepperProvider>(
        builder: (context, provider, _) {
          void handleBack() {
            // If on confirmation, go Home
            if (provider.activeStep == 6) {
              Get.offAllNamed(AppRoutes.bottomNav);
              return;
            }
            // If on the first step (staff selection), back should take user Home
            if (provider.activeStep <= 1) {
              Get.offAllNamed(AppRoutes.bottomNav);
              return;
            }
            // Otherwise, go to previous step within the flow
            provider.goToPreviousStep();
          }

          Widget getCurrent() {
            final activeStep = provider.activeStep;
            final currentSubScreen = provider.currentSubScreen;
            if (activeStep == 1) {
              return BookingStaffsSelectionScreen(
                service: selectedService,
                onStaffSelected: provider.onStaffSelected,
              );
            } else if (activeStep == 2) {
              return DateTimeSelectionScreen(
                onBack: provider.goToPreviousStep,
                onNext: provider.onDateSlotSelected,
                service: selectedService,
                staff: provider.selectedStaff!,
              );
            } else if (activeStep == 3) {
              switch (currentSubScreen) {
                case 0:
                  if (AuthAndNetworkService.isLoggedIn.value) {
                    return BillingScreen(
                      service: selectedService,
                      selectedStaff: provider.selectedStaff,
                      selectedDate: provider.selectedDate,
                      selectedTimeSlot: provider.selectedTimeSlot,
                      onBack: provider.goToPreviousStep,
                      onNext: provider.handleBillingNext,
                    );
                  } else {
                    return BookingLoginScreen(
                      onBack: provider.goToPreviousStep,
                      onNext: provider.handleLoginNext,
                      selectedDate: provider.selectedDate,
                    );
                  }
                case 1:
                  return BillingScreen(
                    service: selectedService,
                    selectedStaff: provider.selectedStaff,
                    selectedDate: provider.selectedDate,
                    selectedTimeSlot: provider.selectedTimeSlot,
                    onBack: provider.goToPreviousStep,
                    onNext: provider.handleBillingNext,
                  );
              }
            } else if (activeStep == 4) {
              return OrderSummaryScreen(
                service: selectedService,
                staff: provider.selectedStaff!,
                bookingDate: provider.selectedDate!,
                bookingTime: provider.selectedTimeSlot!,
                billingDetails: provider.billingDetails!,
                totalAmount: provider.totalAmount!,
                onBack: provider.goToPreviousStep,
                onNext: provider.handleOrderSummaryNext,
              );
            } else if (activeStep == 5) {
              return PaymentScreen(
                onPaymentComplete: provider.handlePaymentComplete,
                service: selectedService,
                staff: provider.selectedStaff!,
                totalAmount: provider.totalAmount!,
                billingDetails: provider.billingDetails!,
                bookingDate: provider.selectedDate!,
                bookingTime: provider.selectedTimeSlot!,
                onBack: provider.goToPreviousStep,
              );
            } else if (activeStep == 6) {
              return PaymentConfirmationScreen(
                onBackToHome: () => Get.offAllNamed(AppRoutes.bottomNav),
                selectedStaff: provider.selectedStaff,
                selectedDate: provider.selectedDate,
                selectedPaymentMethod: provider.selectedPayment,
                selectedTimeSlot: provider.slotToLabel(
                  provider.selectedTimeSlot,
                ),
                services: selectedService,
                bookingId: provider.bookingId,
              );
            }
            return const SizedBox.shrink();
          }

          final activeStep = provider.activeStep;
          final currentSubScreen = provider.currentSubScreen;
          final pageKey = ValueKey('step-$activeStep-sub-$currentSubScreen');

          final stepDisplayIndex = provider.stepDisplayIndex;

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              handleBack();
            },
            child: Scaffold(
              body: Column(
                children: [
                  CustomAppBar(
                    title: 'Service Booking'.tr,
                    onTap: () {
                      handleBack();
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomStepper(activeStep: stepDisplayIndex),
                  const SizedBox(height: 8),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final slideTween = Tween<Offset>(
                          begin: Offset(provider.isForward ? 0.15 : -0.15, 0),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeOutCubic));
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: animation.drive(slideTween),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(key: pageKey, child: getCurrent()),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
