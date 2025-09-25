import 'dart:async';

import 'package:bookapp_customer/features/services_booking/logic/payload_builder.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_context.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_shared.dart';
import 'package:bookapp_customer/features/services_booking/logic/gateway_types.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/progress_overlay.dart';
import 'package:bookapp_customer/network_service/core/checkout_services.dart';
import 'package:flutter/material.dart';
import 'package:bookapp_customer/app/app_strings.dart';

import '../../../../network_service/pgw_services/midtrans.dart';

class MidtransController {
  static Future<void> pay(BuildContext context, PaymentContext pc) async {
    final shared = PaymentShared(pc);
    final overlay = ProgressOverlay.of(context);
  overlay.show(PaymentStrings.verifyingAmount);
    try {
      final num verifiedAmount = await shared.verifyForGatewayOrThrow(
        GatewayType.midtrans,
        overlay,
      );
      await Future.delayed(const Duration(milliseconds: 150));
  overlay.update(PaymentStrings.opening('MidTrans'));
      if (!context.mounted) return;
      final merged = shared.mergedBilling(context);
      final int amountIdr = verifiedAmount.toInt();
      final selectedCcy = shared.selectCurrencyOrThrow(GatewayType.midtrans);
      final ok = await MidtransGateway.startCheckout(
        context: context,
        amountIDR: amountIdr,
        name: merged['name']!,
        email: merged['email']!,
        phone: merged['phone'] ?? '',
        description: 'Service #${pc.service.id} on ${shared.fmtDate(pc.bookingDate)}',
        currency: selectedCcy.toLowerCase(),
      );
      if (!ok) throw PaymentCancelled();
  overlay.update(PaymentStrings.finalizingBooking);
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
        method: 'MidTrans',
        gatewayType: 'online',
      );
      final resp = await CheckoutService.paymentProcess(payload, bearerToken: bearer);
      final bookingId = shared.bookingIdFromResponse(resp);
      pc.onComplete('MidTrans', bookingId);
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
