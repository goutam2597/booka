import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bookapp_customer/features/auth/providers/auth_provider.dart';
import 'package:bookapp_customer/features/services/data/models/services_model.dart';
import 'package:bookapp_customer/features/services_booking/data/available_time_recponse_model.dart';
import 'package:bookapp_customer/features/services_booking/data/staff_model.dart';
import 'package:bookapp_customer/features/services_booking/logic/index.dart'
    hide PaymentShared;
export 'package:bookapp_customer/features/services_booking/logic/gateway_types.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_controllers/payment_shared.dart';

class PaymentController {
  PaymentController({
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
    Map<GatewayType, Set<String>>? supportedCurrenciesOverride,
  }) : supportedCurrencies =
           supportedCurrenciesOverride ?? kDefaultSupportedCurrencies;

  static const Duration kVerifyHardTimeout = Duration(seconds: 10);

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

  /// Per-gateway currency support (overrideable from server).
  final Map<GatewayType, Set<String>> supportedCurrencies;

  String fmtDate(DateTime d) => d.toIso8601String().split('T').first;

  // ---------- Currency support helpers (thin wrappers) ----------
  bool supports(GatewayType g) {
    final app = currency.toUpperCase().trim();
    final set = supportedCurrencies[g] ?? const {};
    return set.contains(app) || set.contains('USD');
  }

  // Build PaymentContext for controllers
  PaymentContext _pc() => PaymentContext(
    service: service,
    staff: staff,
    bookingDate: bookingDate,
    slot: slot,
    billingDetails: billingDetails,
    totalAmountMinor: totalAmountMinor,
    readAuth: readAuth,
    onComplete: onComplete,
    onUserCancel: onUserCancel,
    onError: onError,
    onSuccessToast: onSuccessToast,
    currency: currency,
    supportedCurrencies: supportedCurrencies,
  );

  List<GatewayType> availableGateways() =>
      GatewayType.values.where(supports).toList();

  String? currencyErrorFor(GatewayType g) {
    if (supports(g)) return null;
    final ccy = currency.toUpperCase().trim();
    final label = gatewayLabel(g);
    return '$label is unavailable for $ccy.';
  }

  // -------------------- MYFATOORAH (Hosted) --------------------
  Future<void> payWithMyFatoorah(BuildContext context) async =>
      MyFatoorahController.pay(context, _pc());

  // -------------------- MERCADO PAGO (Hosted) --------------------
  Future<void> payWithMercadoPago(BuildContext context) async =>
      MercadoPagoController.pay(context, _pc());

  // -------------------- MONNIFY (Hosted) --------------------
  Future<void> payWithMonnify(BuildContext context) async =>
      MonnifyController.pay(context, _pc());

  // -------------------- NOWPAYMENTS (Hosted) --------------------
  Future<void> payWithNowPayments(BuildContext context) async =>
      NowPaymentsController.pay(context, _pc());

  // -------------------- STRIPE --------------------
  Future<void> payWithStripe(BuildContext context) async =>
      StripeController.pay(context, _pc());

  // -------------------- FLUTTERWAVE --------------------
  Future<void> payWithFlutterwave(BuildContext context) async =>
      FlutterwaveController.pay(context, _pc());

  // -------------------- PAYPAL (Hosted) --------------------
  Future<void> payWithPayPal(BuildContext context) async =>
      PayPalController.pay(context, _pc());

  // -------------------- PAYSTACK --------------------
  Future<void> payWithPayStack(BuildContext context) async =>
      PayStackController.pay(context, _pc());

  // -------------------- MOLLIE (Hosted) --------------------
  Future<void> payWithMollie(BuildContext context) async =>
      MollieController.pay(context, _pc());

  // -------------------- XENDIT (Hosted) --------------------
  Future<void> payWithXendit(BuildContext context) async =>
      XenditController.pay(context, _pc());

  // -------------------- TOYYIBPAY (Hosted) --------------------
  Future<void> payWithToyyibpay(BuildContext context) async =>
      ToyyibpayController.pay(context, _pc());

  // -------------------- RAZORPAY--------------------
  Future<void> payWithRazorpaySdk(BuildContext context) async =>
      RazorpayController.pay(context, _pc());

  // -------------------- AUTHORIZE.NET --------------------
  Future<void> payWithAuthorizeNet(BuildContext context) async =>
      AuthorizeNetController.pay(context, _pc());

  // -------------------- MIDTRANS (Snap hosted) --------------------
  Future<void> payWithMidtrans(BuildContext context) async =>
      MidtransController.pay(context, _pc());

  // -------------------- PHONEPE (Hosted) --------------------
  Future<void> payWithPhonePe(BuildContext context) async =>
      PhonePeController.pay(context, _pc());

  // -------------------- OFFLINE (Manual) --------------------
  Future<void> payWithOffline(
    BuildContext context, {
    required String gatewayName,
    String instructions = '',
    String attachmentFieldName = 'attachment',
    bool showAttachment = true,
    bool attachmentRequired = false,
  }) async {
    final shared = PaymentShared(_pc());
    await shared.runOfflinePayment(
      context: context,
      gatewayName: gatewayName,
      instructions: instructions,
      attachmentFieldName: attachmentFieldName,
      showAttachment: showAttachment,
      attachmentRequired: attachmentRequired,
    );
  }
}
