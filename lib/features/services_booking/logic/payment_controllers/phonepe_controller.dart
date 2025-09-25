import 'dart:async';

import 'package:bookapp_customer/features/services_booking/logic/payload_builder.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_context.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_shared.dart';
import 'package:bookapp_customer/features/services_booking/logic/gateway_types.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/progress_overlay.dart';
import 'package:bookapp_customer/network_service/core/checkout_services.dart';
import 'package:flutter/material.dart';
import 'package:bookapp_customer/app/app_strings.dart';

import '../../../../network_service/pgw_services/phonepe.dart';

class PhonePeController {
  static Future<void> pay(BuildContext context, PaymentContext pc) async {
    final shared = PaymentShared(pc);
    final overlay = ProgressOverlay.of(context);
  overlay.show(PaymentStrings.verifyingAmount);
    try {
      final selectedCcy = shared.selectCurrencyOrThrow(GatewayType.phonePe);
      final num verifiedAmount = await shared.verifyForGatewayOrThrow(
        GatewayType.phonePe,
        overlay,
      );
      final int verifiedMinor = (verifiedAmount * 100).round();
      await Future.delayed(const Duration(milliseconds: 150));
  overlay.update(PaymentStrings.opening('PhonePe'));
      if (!context.mounted) return;
      final merged = shared.mergedBilling(context);
      final ok = await PhonePeGateway.startCheckout(
        context: context,
        amountMinor: verifiedMinor,
        merchantUserId: shared.resolveUserId() ?? '0',
        name: merged['name'] ?? 'User',
        email: merged['email'] ?? 'customer@example.com',
        mobile: merged['phone'] ?? '',
        description: 'Service #${pc.service.id} on ${shared.fmtDate(pc.bookingDate)}',
        currency: selectedCcy,
      );
    if (!ok) throw PaymentCancelled();
    // Ensure loading is visible after returning from the hosted flow
    // (show() will re-open the dialog if it was closed, or just update if still visible)
    overlay.show(PaymentStrings.finalizingBooking);
      final userId = shared.resolveUserId();
      final bearer = shared.resolveBearerToken();
      final payload = BookingPayload.build(
        amountMajor: verifiedAmount.toDouble(),
        service: pc.service,
        staff: pc.staff,
        bookingDate: pc.bookingDate,
        slot: pc.slot,
        mergedBilling: merged,
        persons: pc.billingDetails['persons'] ?? '1',
        userId: userId ?? '0',
        method: 'PhonePe',
        gatewayType: 'online',
      );
      final resp = await CheckoutService.paymentProcess(payload, bearerToken: bearer);
      final bookingId = shared.bookingIdFromResponse(resp);
      pc.onComplete('PhonePe', bookingId);
      pc.onSuccessToast();
    } on TimeoutException {
      pc.onError(PaymentStrings.verifyTimeout);
    } on PaymentCancelled {
      pc.onUserCancel();
    } on PaymentException catch (e) {
      pc.onError(e.message);
    } catch (e) {
      pc.onError('${PaymentStrings.paymentNotSuccessful} $e');
    } finally {
      overlay.hide();
    }
  }
}
