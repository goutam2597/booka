import 'dart:convert';
import 'package:bookapp_customer/app/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:bookapp_customer/network_service/http_headers.dart';

import '../../app/routes/app_routes.dart';

class MidtransGateway {
  static Future<bool> startCheckout({
    required BuildContext context,
    required int amountIDR,
    required String name,
    required String email,
    required String phone,
    String description = 'Order',
    required String currency,
  }) async {
    // 1) Create Snap transaction on your server
    final res = await http.post(
      Uri.parse('$pgwBaseUrl/midtrans-create-snap.php'),
      headers: {
        ...HttpHeadersHelper.base(),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'currency': currency,
        'amount': amountIDR,
        'name': name,
        'email': email,
        'phone': phone,
        'description': description,
      }),
    );
    if (res.statusCode >= 300) {
      throw Exception('MidTrans creation failed: ${res.body}');
    }

    final snap = jsonDecode(res.body) as Map<String, dynamic>;
    final redirectUrl = snap['redirect_url'] as String?;
    final orderId = snap['order_id'] as String?;

    if (redirectUrl == null || orderId == null || !context.mounted) {
      throw Exception('Missing redirect_url or order_id');
    }

    final finished = await Get.toNamed(
      AppRoutes.checkoutWebView,
      arguments: {
        'url': redirectUrl,
        'finishScheme': 'myapp://midtrans-finish',
        'title': 'MidTrans',
      },
    ) as bool?;

    if (finished != true) return false;

    final st = await http.get(
      Uri.parse('$pgwBaseUrl/midtrans-order-status.php?order_id=$orderId'),
      headers: HttpHeadersHelper.base(),
    );
    if (st.statusCode >= 300) {
      throw Exception('Status check failed: ${st.body}');
    }

    final status = jsonDecode(st.body) as Map<String, dynamic>;
    final txn = (status['transaction_status'] ?? '').toString().toLowerCase();

    return txn == 'settlement' || txn == 'capture' || txn == 'success';
  }
}
