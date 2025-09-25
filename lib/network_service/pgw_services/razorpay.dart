import 'dart:async';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:bookapp_customer/network_service/core/basic_service.dart';

class RazorpaySdkGateway {
  static Razorpay? _rzp;

  static void _ensure() {
    _rzp ??= Razorpay();
  }

  static Future<bool> startCheckout({
    required BuildContext context,
    required int amountMinor,
    required String name,
    required String currency,
    required String email,
    required String phone,
    String description = 'Order',
    String? key,
  }) async {
    _ensure();

    final completer = Completer<bool>();

    void handleSuccess(PaymentSuccessResponse r) {
      if (!completer.isCompleted) completer.complete(true);
    }

    void handleError(PaymentFailureResponse r) {
      final isCancelled = r.code == 2;
      if (isCancelled) {
        if (!completer.isCompleted) completer.complete(false);
        return;
      }
      if (!completer.isCompleted) {
        completer.completeError(
          Exception('Razorpay error ${r.code}: ${r.message}'),
        );
      }
    }

    void handleExternalWallet(ExternalWalletResponse r) {}

    _rzp!.on(Razorpay.EVENT_PAYMENT_SUCCESS, handleSuccess);
    _rzp!.on(Razorpay.EVENT_PAYMENT_ERROR, handleError);
    _rzp!.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);

    try {
      // Key must be provided by backend get-basic
      final apiKey = await BasicService.getRazorpayKey();
      final useKey = (apiKey != null && apiKey.isNotEmpty) ? apiKey : key;
      if (useKey == null || useKey.isEmpty) {
        throw Exception('Razorpay key not provided by API');
      }

      final options = {
        'key': useKey,
        'amount': amountMinor,
        'currency': currency.toUpperCase(),
        'name': name,
        'description': description,
        'prefill': {'contact': phone, 'email': email},
      };
      _rzp!.open(options);
      final ok = await completer.future;
      return ok;
    } finally {
      _rzp!.clear();
      _rzp = null;
    }
  }
}
