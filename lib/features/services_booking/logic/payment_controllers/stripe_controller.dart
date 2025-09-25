import 'package:bookapp_customer/features/services_booking/logic/payment_context.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_shared.dart';
import 'package:bookapp_customer/features/services_booking/logic/gateway_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../../network_service/pgw_services/stripe.dart';

class StripeController {
  static Future<void> pay(BuildContext context, PaymentContext pc) async {
    final shared = PaymentShared(pc);
    await shared.runHostedGateway(
      context: context,
      gateway: GatewayType.stripe,
      openingLabel: 'Stripe',
      methodLabel: 'Stripe',
      openAndConfirm: (ctx, merged, verifiedAmount, minor, selectedCcyLower) async {
        try {
          final ok = await StripeServerGateway.startCardPayment(
            context: ctx,
            amountMinor: minor,
            currency: selectedCcyLower,
            merchantName: 'BookApp',
          );
          return ok;
        } on StripeException catch (e) {
          if (e.error.code == FailureCode.Canceled) return false;
          rethrow;
        }
      },
    );
  }
}
