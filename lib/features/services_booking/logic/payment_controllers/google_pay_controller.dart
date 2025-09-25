import 'package:bookapp_customer/features/common/ui/widgets/custom_cpi.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_context.dart';
import 'package:bookapp_customer/features/services_booking/logic/payment_shared.dart';
import 'package:bookapp_customer/features/services_booking/logic/gateway_types.dart';
import 'package:flutter/material.dart';
import 'package:bookapp_customer/app/app_strings.dart';
import 'package:pay/pay.dart';

import '../../../../network_service/pgw_services/google_pay.dart';

class GooglePayController {
  static Future<void> pay(BuildContext context, PaymentContext pc) async {
    final shared = PaymentShared(pc);
    await shared.runHostedGateway(
      context: context,
      gateway: GatewayType.googlePay,
      openingLabel: 'Google Pay',
      methodLabel: 'Google Pay',
      openAndConfirm:
          (ctx, merged, verifiedAmount, minor, selectedCcyLower) async {
            final gpayConfigJson = await DefaultAssetBundle.of(
              ctx,
            ).loadString('assets/google_pay_config.json');
            if (!ctx.mounted) return false;
            final result = await showModalBottomSheet<dynamic>(
              backgroundColor: Colors.white,
              context: ctx,
              useSafeArea: true,
              isScrollControlled: true,
              builder: (sheetCtx) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: GooglePayButton(
                    paymentConfiguration: PaymentConfiguration.fromJsonString(
                      gpayConfigJson,
                    ),
                    paymentItems: [
                      PaymentItem(
                        label: AppStrings.total,
                        amount: verifiedAmount.toStringAsFixed(2),
                        status: PaymentItemStatus.final_price,
                      ),
                    ],
                    type: GooglePayButtonType.pay,
                    onPaymentResult: (payload) {
                      Navigator.of(sheetCtx).maybePop(payload);
                    },
                    loadingIndicator: Center(child: const CustomCPI()),
                  ),
                ),
              ),
            );
            if (!ctx.mounted || result == null) return false;
            final ok = await GooglePayStripeGateway.onPaymentResult(
              context: ctx,
              result: result,
              amountMinor: minor,
              currency: selectedCcyLower,
            );
            return ok == true;
          },
    );
  }
}
