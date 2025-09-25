import 'dart:async';
import 'package:bookapp_customer/features/services_booking/logic/payload_builder.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_context.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_shared.dart';
import 'package:bookapp_customer/features/services_booking/logic/gateway_types.dart';
import 'package:bookapp_customer/features/services_booking/ui/widgets/progress_overlay.dart';
import 'package:bookapp_customer/network_service/core/checkout_services.dart';
import 'package:flutter/material.dart';
import 'package:bookapp_customer/app/app_strings.dart';

import '../../../../network_service/pgw_services/myfatoorah.dart';

class MyFatoorahController {
  static Future<void> pay(BuildContext context, PaymentContext pc) async {
    final shared = PaymentShared(pc);
    final overlay = ProgressOverlay.of(context);
  overlay.show(PaymentStrings.checkingCurrency);
    try {
      shared.ensureCurrencySupported(GatewayType.myfatoorah);
  overlay.update(PaymentStrings.verifyingAmount);
      final num verifiedAmount = await shared.verifyForGatewayOrThrow(
        GatewayType.myfatoorah,
        overlay,
      );
      final int verifiedMinor = (verifiedAmount * 100).round();
      await Future.delayed(const Duration(milliseconds: 150));
  overlay.update(PaymentStrings.opening('MyFatoorah'));
      if (!context.mounted) return;
      final merged = shared.mergedBilling(context);
      final ok = await MyFatoorahGateway.startCheckout(
        context: context,
        amountMinor: verifiedMinor,
  currency: shared.selectCurrencyOrThrow(GatewayType.myfatoorah).toLowerCase(),
        name: merged['name']!,
        email: merged['email']!,
        phone: merged['phone'] ?? '',
        description: 'Service #${pc.service.id} on ${shared.fmtDate(pc.bookingDate)}',
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
        method: 'MyFatoorah',
        gatewayType: 'online',
      );
      final resp = await CheckoutService.paymentProcess(payload, bearerToken: bearer);
      final bookingId = shared.bookingIdFromResponse(resp);
      pc.onComplete('MyFatoorah', bookingId);
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
