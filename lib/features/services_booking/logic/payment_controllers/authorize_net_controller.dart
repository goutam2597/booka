import 'dart:async';
import 'package:bookapp_customer/features/services_booking/logic/payload_builder.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_context.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_shared.dart';
import 'package:bookapp_customer/features/services_booking/logic/gateway_types.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/progress_overlay.dart';
import 'package:bookapp_customer/network_service/core/checkout_services.dart';
import 'package:flutter/material.dart';
import 'package:bookapp_customer/app/app_strings.dart';

import '../../../../network_service/pgw_services/authorize_net.dart';

class AuthorizeNetController {
  static Future<void> pay(BuildContext context, PaymentContext pc) async {
    final shared = PaymentShared(pc);
    final overlay = ProgressOverlay.of(context);
    overlay.show(PaymentStrings.verifyingAmount);
    try {
      final num verifiedAmount = await shared.verifyForGatewayOrThrow(
        GatewayType.authorize_net,
        overlay,
      );
      await Future.delayed(const Duration(milliseconds: 150));
      overlay.update(PaymentStrings.opening('Authorize.Net'));
      if (!context.mounted) return;
      final selectedCcy = shared.selectCurrencyOrThrow(
        GatewayType.authorize_net,
      );
      final ok = await AuthorizeNetGateway.startCheckout(
        context: context,
        amountString: verifiedAmount.toStringAsFixed(2),
        currency: selectedCcy.toLowerCase(),
      );
      if (!ok) throw PaymentCancelled();
      overlay.update(PaymentStrings.finalizingBooking);
      final userId = shared.resolveUserId();
      final bearer = shared.resolveBearerToken();
      if (!context.mounted) return;
      final merged = shared.mergedBilling(context);
      final payload = BookingPayload.build(
        amountMajor: verifiedAmount.toDouble(),
        service: pc.service,
        staff: pc.staff,
        bookingDate: pc.bookingDate,
        slot: pc.slot,
        mergedBilling: merged,
        persons: pc.billingDetails['persons'] ?? '1',
        userId: userId ?? '0',
        method: 'Authorize.Net',
        gatewayType: 'online',
      );
      final resp = await CheckoutService.paymentProcess(
        payload,
        bearerToken: bearer,
      );
      final bookingId = shared.bookingIdFromResponse(resp);
      pc.onComplete('Authorize.Net', bookingId);
      pc.onSuccessToast();
    } on TimeoutException {
      pc.onError(PaymentStrings.verifyTimeout);
    } on PaymentCancelled {
      pc.onUserCancel();
    } catch (e) {
      pc.onError('${PaymentStrings.paymentNotSuccessful} $e');
    } finally {
      overlay.hide();
    }
  }
}
