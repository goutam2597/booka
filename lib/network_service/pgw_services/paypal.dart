import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:bookapp_customer/network_service/http_headers.dart';

import '../../app/routes/app_routes.dart';
import '../../app/app_constants.dart';

class PayPalGateway {
  static Future<bool> startCheckout({
    required BuildContext context,
    required int amountMinor,
    required String currency,
    required String name,
    required String email,
    String description = 'Order',
  }) async {
    // 1) Create order on your server
    final create = await http.post(
      Uri.parse('$pgwBaseUrl/paypal-create-order.php'),
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

    if (create.statusCode >= 300 && !context.mounted) {
      throw Exception('PayPal create failed: ${create.body}');
    }

    final j = jsonDecode(create.body) as Map<String, dynamic>;
    final approveUrl = j['redirect_url'] as String?;
    final orderId = j['order_id'] as String?;
    if (approveUrl == null || orderId == null) {
      throw Exception('Missing approve link/order_id');
    }

    final finished =
        await Get.toNamed(
              AppRoutes.checkoutWebView,
              arguments: {
                'url': approveUrl,
                'finishScheme': 'myapp://paypal-finish',
                'title': 'PayPal',
              },
            )
            as bool?;

    if (finished != true) return false; // user cancelled

    // 3) Capture on server (finalize order on PayPal)
    final cap = await http.post(
      Uri.parse('$pgwBaseUrl/paypal-capture-order.php'),
      headers: {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'order_id': orderId}),
    );
    if (cap.statusCode >= 300) {
      throw Exception('Capture failed: ${cap.body}');
    }
    final c = jsonDecode(cap.body) as Map<String, dynamic>;
    final status = (c['status'] ?? 'UNKNOWN').toString().toUpperCase();

    return status == 'COMPLETED';
  }
}
