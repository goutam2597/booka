import 'package:bookapp_customer/features/services_booking/logic/payment_context.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_shared.dart';
import 'package:bookapp_customer/features/services_booking/logic/gateway_types.dart';
import 'package:flutter/material.dart';

import '../../../../network_service/pgw_services/paypal.dart';

class PayPalController {
  static Future<void> pay(BuildContext context, PaymentContext pc) async {
    final shared = PaymentShared(pc);
    await shared.runHostedGateway(
      context: context,
      gateway: GatewayType.paypal,
      openingLabel: 'PayPal',
      methodLabel: 'PayPal',
      openAndConfirm: (ctx, merged, major, minor, selectedCcyLower) async {
        return PayPalGateway.startCheckout(
          context: ctx,
          amountMinor: minor,
          currency: selectedCcyLower,
          name: merged['name']!,
          email: merged['email']!,
          description: 'Service #${pc.service.id} on ${shared.fmtDate(pc.bookingDate)}',
        );
      },
    );
  }
}
