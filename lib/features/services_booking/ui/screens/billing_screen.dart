import 'package:bookapp_customer/app/app_colors.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/common/ui/widgets/custom_header_text_widget.dart';
import 'package:bookapp_customer/features/common/ui/widgets/form_header_text_widget.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services_booking/data/available_time_recponse_model.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:bookapp_customer/features/services_booking/providers/billing_provider.dart';
import 'package:bookapp_customer/features/auth/providers/auth_provider.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/booking_text_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// Removed unused AuthAndNetworkService import after provider refactor.

class BillingScreen extends StatelessWidget {
  final Function(Map<String, String> billingDetails, int totalAmount) onNext;
  final VoidCallback onBack;
  final ServicesModel service;
  final StaffModel? selectedStaff;
  final DateTime? selectedDate;
  final AvailableTimeResponseModel? selectedTimeSlot;

  const BillingScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.service,
    required this.selectedStaff,
    required this.selectedDate,
    required this.selectedTimeSlot,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => BillingProvider(
        service: service,
        readAuth: () => ctx.read<AuthProvider>(),
      ),
      builder: (context, _) {
        final p = context.watch<BillingProvider>();
        if (p.loading) {
          return const Scaffold(body: Center(child: CustomCPI()));
        }
        return _buildForm(context, p);
      },
    );
  }

  Widget _buildRowFields(BillingProvider p) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormHeaderTextWidget(text: 'Postcode/Zip'),
              const SizedBox(height: 4),
              TextFormField(
                controller: p.zipCodeController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormHeaderTextWidget(text: 'Country'),
              const SizedBox(height: 4),
              TextFormField(
                controller: p.countryController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context, BillingProvider p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BookingTextButtonWidget(
          onTap: onBack,
          text: 'Prev Step',
          icon: Icons.arrow_back,
        ),
        BookingTextButtonWidget(
          onTap: () => _handleNext(context, p),
          text: 'Next Step',
          icon: Icons.arrow_forward,
          iconRight: true,
          textColor: AppColors.primaryColor,
          iconColor: AppColors.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, BillingProvider p) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onBack();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: p.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: CustomHeaderTextWidget(text: 'Billing Details'),
                ),
                const SizedBox(height: 32),
                const FormHeaderTextWidget(text: 'Full Name'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: p.fullNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter your full name'
                      : null,
                ),
                const SizedBox(height: 16),
                const FormHeaderTextWidget(text: 'Phone Number'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: p.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter your phone number'
                      : null,
                ),
                const SizedBox(height: 16),
                const FormHeaderTextWidget(text: 'Email Address'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: p.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Enter Your Email Address'.tr
                      : null,
                ),
                const SizedBox(height: 16),
                const FormHeaderTextWidget(text: 'Address'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: p.addressController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter your address'.tr
                      : null,
                ),
                const SizedBox(height: 16),
                _buildRowFields(p),
                const SizedBox(height: 16),
                _buildNavigationButtons(context, p),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNext(BuildContext context, BillingProvider p) {
    if (!p.formKey.currentState!.validate()) return;
    if (selectedStaff == null ||
        selectedDate == null ||
        selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select staff, date, and time slot'),
        ),
      );
      return;
    }
    final billingDetails = p.collectBillingDetails();
    final totalAmount = p.calculateTotalAmount();
    onNext(billingDetails, totalAmount);
  }
}
