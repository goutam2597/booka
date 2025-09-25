import 'package:bookapp_customer/features/auth/providers/auth_provider.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services_booking/data/available_time_recponse_model.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:bookapp_customer/features/services_booking/logic/gateway_types.dart';
import 'package:flutter/material.dart';

class PaymentContext {
  final ServicesModel service;
  final StaffModel staff;
  final DateTime bookingDate;
  final AvailableTimeResponseModel slot;
  final Map<String, String> billingDetails;
  final int totalAmountMinor;
  final AuthProvider Function() readAuth;
  final void Function(String paymentMethod, String? bookingId) onComplete;
  final VoidCallback onUserCancel;
  final void Function(String message) onError;
  final VoidCallback onSuccessToast;
  final String currency;
  final Map<GatewayType, Set<String>> supportedCurrencies;

  PaymentContext({
    required this.service,
    required this.staff,
    required this.bookingDate,
    required this.slot,
    required this.billingDetails,
    required this.totalAmountMinor,
    required this.readAuth,
    required this.onComplete,
    required this.onUserCancel,
    required this.onError,
    required this.onSuccessToast,
    required this.currency,
    required this.supportedCurrencies,
  });
}
