import 'dart:convert';
import 'package:bookapp_customer/app/app_constants.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../app/routes/app_routes.dart';

class MollieGateway {
  /// Starts a hosted checkout with Mollie via your backend.
  static Future<bool> startCheckout({
    required BuildContext context,
    required int amountMinor, // cents
    required String currency, // e.g. "USD"
    required String name,
    required String email,
    String description = 'Order',
  }) async {
    // 1) Create payment on server
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/mollie-create-payment.php'),
      headers: {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount_minor': amountMinor,
        'currency': currency.toUpperCase(),
        'name': name,
        'email': email,
        'description': description,
      }),
    );

    if (res.statusCode >= 300) {
      throw Exception('Mollie create failed: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final checkoutUrl = data['checkout_url'] as String?;
    final paymentId = data['payment_id'] as String?;
    if (checkoutUrl == null ||
        paymentId == null ||
        (context.mounted == false)) {
      throw Exception('Missing checkout_url/payment_id');
    }

    // 2) Open hosted checkout
    final finished =
        await Get.toNamed(
              AppRoutes.checkoutWebView,
              arguments: {
                'url': checkoutUrl,
                'finishScheme': 'myapp://mollie-finish',
                'title': 'Mollie',
              },
            )
            as bool?;

    if (finished != true) return false;

    // 3) Verify status on server
    final st = await http.get(
      Uri.parse('$pgwBaseUrl/mollie-status.php?payment_id=$paymentId'),
      headers: HttpHeadersHelper.base(),
    );
    if (st.statusCode >= 300) {
      throw Exception('Status failed: ${st.body}');
    }

    bool isPaid(dynamic decoded) {
      if (decoded is Map<String, dynamic>) {
        final s = (decoded['status'] ?? '').toString().toLowerCase();
        return s == 'paid' || s == 'paid_out' || s == 'authorized';
      }
      if (decoded is String) {
        final up = decoded.toLowerCase();
        return up.contains('paid');
      }
      return false;
    }

    try {
      final js = jsonDecode(st.body);
      return isPaid(js);
    } catch (_) {
      return isPaid(st.body);
    }
  }
}
