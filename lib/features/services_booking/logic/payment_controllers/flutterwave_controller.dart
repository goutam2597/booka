import 'package:bookapp_customer/features/services_booking/logic/payment_context.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_shared.dart';
import 'package:bookapp_customer/features/services_booking/logic/gateway_types.dart';
import 'package:flutter/material.dart';

import '../../../../network_service/pgw_services/flutterwave.dart';

class FlutterwaveController {
  static Future<void> pay(BuildContext context, PaymentContext pc) async {
    final shared = PaymentShared(pc);
    await shared.runHostedGateway(
      context: context,
      gateway: GatewayType.flutterWave,
      openingLabel: 'FlutterWave',
      methodLabel: 'FlutterWave',
      openAndConfirm: (ctx, merged, major, minor, selectedCcyLower) async {
        return FlutterwaveGateway.startCheckout(
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
